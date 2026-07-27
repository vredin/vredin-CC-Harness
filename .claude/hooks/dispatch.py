#!/usr/bin/env python3
"""dispatch.py — unified PreToolUse hook dispatcher.

Official Claude Code hook contract: JSON on stdin —
  {"hook_event_name": "PreToolUse", "tool_name": "Edit|Write|Bash|...",
   "tool_input": {"file_path": "...", "command": "...", ...},
   "session_id": "...", "cwd": "...", "transcript_path": "..."}

Blocking a PreToolUse call = exit 2, reason on stderr.

Usage (from .claude/settings.json):
  python3 "$CLAUDE_PROJECT_DIR/.claude/hooks/dispatch.py" PreToolUse

Rules:
  File tools (Edit|Write|NotebookEdit):
    (R1 backup-gate removed 2026-07-03 — ordinary file edits are insured by native
     Claude Code checkpoints (/rewind); [BACKUP] commits remain mandatory only for
     ops checkpoints don't cover — see .claude/rules/workflow.md § Pre-Change Protocol)
    R2 config-protection  — CLAUDE.md / .claude/settings.json need explicit user consent
                            (bypass: CLAUDE_CONFIG_EDIT_OK=1)
    R3 security reminder  — delegate code files to security_reminder_hook.py (stdin passthrough)
    R4 todo-diablo-gate   — docs/TASK.md edits delegate to todo-diablo-gate.sh
  Bash tool:
    R5 commit-prefix      — git commit -m must start with [BACKUP|CHANGE|META|HANDOFF|PROCESS|RULES|SEC|FIX|WIP]
    R6 task-id-validator  — T-NNN in commit message requires docs/specs/T-NNN-*.md (delegated)
    R7 destructive-shell  — rm -rf, git reset --hard, force push, git clean -fd, git rm on
                            .claude|CLAUDE.md, broad git add (-A/--all/.) (bypass: CLAUDE_ALLOW_BROAD_ADD=1)
    R8 destructive-SQL    — DROP TABLE/DATABASE/SCHEMA, TRUNCATE, DELETE without WHERE
    R9 size-guard         — git add paths / git commit staged files >1MB blocked
                            (bypass: CLAUDE_ALLOW_BIG_FILE=1)
    R10 gitleaks-gate     — git commit scans staged changes with gitleaks when the
                            binary is installed; findings block, missing binary skips
                            silently (one hook-errors.log line per day)
    R11 tests-prod-db     — integration tests aimed at a non-test DB URL, or pytest
                            inside a container without an explicit TEST_*_URL=…test…
                            (F-161: prod schema wiped by test teardown; bypass:
                            CLAUDE_ALLOW_DESTRUCTIVE=1)
    R12 volume-wipe       — docker compose down -v / docker volume rm|prune erase
                            databases; blocked local AND inside ssh payloads
                            (bypass: CLAUDE_ALLOW_DESTRUCTIVE=1)

Failure policy: fail-open. Any JSON parse error or internal exception → exit 0 and
one line appended to .claude/session-log/hook-errors.log. Only deliberate rule
blocks exit 2. stdlib only.
"""

import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HOOKS_DIR = Path(__file__).resolve().parent

CODE_EXTENSIONS = {
    ".py", ".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs", ".yml", ".yaml",
    ".sh", ".bash", ".rb", ".go", ".rs", ".java", ".kt", ".php", ".c",
    ".cpp", ".h", ".hpp",
}

COMMIT_PREFIX_RE = re.compile(
    r"^\[(BACKUP|CHANGE|META|HANDOFF|PROCESS|RULES|SEC|FIX|WIP)\]"
)

DESTRUCTIVE_SHELL_RE = re.compile(
    r"rm\s+-rf"
    r"|rm\s+-[a-z]*r[a-z]*f"
    # git init not blocked: /init-project scaffolds repos, and the literal inside
    # grep/echo strings caused false positives (OSINT backport 2026-07)
    r"|git\s+reset\s+--hard"
    r"|git\s+push\s+--force(?!-with-lease)\b"       # --force but not --force-with-lease (safe variant)
    r"|git\s+push\s+-[a-z]*f[a-z]*\b"                # -f anywhere in combined flags (-f, -fv, -vf)
    r"|git\s+push\b[^;|\n&]+\s-[a-z]*f[a-z]*\b"    # -f after args (git push origin main -f, -fv)
    r"|git\s+checkout\s+--(?:\s|$)"                 # discard working-tree changes
    r"|git\s+commit\b[^;|\n&]*--no-verify\b"        # bypass pre-commit hooks
    r"|git\s+clean\s+-[a-z]*f[a-z]*d"
    r"|git\s+rm\s+(--cached\s+)?-?[a-z]*r?[a-z]*\s*(\.claude|CLAUDE\.md)",
    re.IGNORECASE,
)

BROAD_GIT_ADD_RE = re.compile(r"git\s+add\s+(?:-A\b|--all\b|\.(?=\s|$|;|\)|\"|'))")

DESTRUCTIVE_SQL_RE = re.compile(
    r"DROP\s+(TABLE|DATABASE|SCHEMA)"
    r"|TRUNCATE\s+TABLE"
    r"|TRUNCATE\s+[a-z_]+",
    re.IGNORECASE,
)

DELETE_NO_WHERE_RE = re.compile(
    r"DELETE\s+FROM\s+(?:`[^`]+`|\"[^\"]+\"|[\w.]+)",
    re.IGNORECASE,
)

# R11 (F-161 OSINT 2026-07-16): integration tests must never target a non-test DB.
# A test run from the prod image wiped prod's public schema: teardown ran DROP SCHEMA
# on an inherited DB_MIGRATE_URL. Generalized from OSINT T-476.
INTEG_TEST_RE = re.compile(
    r"pytest\b[^\n]*tests/integration|pytest\b[^\n]*-m\s+integration"
)
DB_URL_ASSIGN_RE = re.compile(
    r"(DB_MIGRATE_URL|DATABASE_URL|DB_URL|TEST_DATABASE_URL(?:_SYNC)?|TEST_DB_URL)"
    r"=(\S+)"
)
TEST_DB_URL_ASSIGN_RE = re.compile(r"TEST_(?:DATABASE|DB)\w*_URL\w*=\S*test", re.IGNORECASE)
CONTAINER_RUN_RE = re.compile(r"docker(?:\s+compose)?\s+(?:compose\s+)?(?:run|exec)\b|docker-compose\s+(?:run|exec)\b")

# R12: container/volume vectors whose destructive payload is invisible to string
# matching (the DROP lives in code inside the container, not in the command).
VOLUME_WIPE_RE = re.compile(
    r"docker(?:-|\s+)compose\s+[^\n]*down\s+[^\n]*(?:-v\b|--volumes\b)"
    r"|docker\s+volume\s+(?:rm|prune)\b"
)

SIZE_GUARD_LIMIT_BYTES = 1024 * 1024  # 1MB

# `git add <args>` — middle tokens must not cross shell separators, so
# `git log && echo add x` does not match. Group 1 = argument tail up to separator.
GIT_ADD_ARGS_RE = re.compile(r"git(?:\s+[^\s;&|]+)*?\s+add\s+([^;&|]*)")

GIT_COMMIT_RE = re.compile(r"git(\s+\S+)*?\s+commit\b")


def project_dir() -> Path:
    env = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if env:
        return Path(env)
    # .claude/hooks/dispatch.py → project root is two levels up from hooks/
    return HOOKS_DIR.parent.parent


def log_error(message: str) -> None:
    """One-line append to hook-errors.log. Never raises."""
    try:
        log_dir = project_dir() / ".claude" / "session-log"
        log_dir.mkdir(parents=True, exist_ok=True)
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        with open(log_dir / "hook-errors.log", "a", encoding="utf-8") as fh:
            fh.write(f"{ts} dispatch.py: {message}\n")
    except Exception:
        pass


def block(message: str) -> None:
    """Deny the tool call: reason to stderr, exit 2."""
    print(message, file=sys.stderr)
    sys.exit(2)


def _git(args, cwd):
    """Run git, return stdout stripped or None on failure."""
    try:
        proc = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=10,
        )
    except Exception:
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout.strip()


# ---------------------------------------------------------------- file rules


def rule_config_protection(file_path: str) -> None:
    """R2: block edits to CLAUDE.md and .claude/settings.json without user consent."""
    if os.environ.get("CLAUDE_CONFIG_EDIT_OK", "") == "1":
        return
    base = os.path.basename(file_path)
    if base not in ("CLAUDE.md", "settings.json"):
        return
    norm = file_path.replace("\\", "/")
    in_claude_dir = "/.claude/" in norm or norm.startswith(".claude/")
    # A bare 'settings.json' (no directory separator) can occur when Claude's cwd
    # is already .claude/ — treat it as protected to prevent silent config mutation.
    is_bare_settings = base == "settings.json" and "/" not in norm
    if base == "CLAUDE.md" or in_claude_dir or is_bare_settings:
        block(
            f"[PROTECTED] {base} is a critical config file.\n"
            "Ask the user to confirm before editing.\n"
            "Bypass (after explicit user approval): CLAUDE_CONFIG_EDIT_OK=1"
        )


def rule_security_reminder(file_path: str, raw_stdin: str) -> None:
    """R3: delegate code-file edits to security_reminder_hook.py, forwarding raw stdin JSON."""
    ext = os.path.splitext(file_path)[1].lower()
    if ext not in CODE_EXTENSIONS:
        return
    script = HOOKS_DIR / "security_reminder" / "security_reminder_hook.py"
    if not script.is_file():
        return
    try:
        proc = subprocess.run(
            [sys.executable or "python3", str(script)],
            input=raw_stdin,
            capture_output=True,
            text=True,
            timeout=30,
        )
    except Exception as exc:
        log_error(f"R3 security_reminder subprocess failed: {exc}")
        return
    if proc.stdout:
        sys.stdout.write(proc.stdout)
    if proc.stderr:
        sys.stderr.write(proc.stderr)
    if proc.returncode != 0:
        sys.exit(proc.returncode)


def rule_todo_diablo_gate(file_path: str, tool_input: dict, cwd: str) -> None:
    """R4: docs/TASK.md edits → todo-diablo-gate.sh (argv: file_path, new content)."""
    norm = file_path.replace("\\", "/")
    if not norm.endswith("docs/TASK.md"):
        return
    script = HOOKS_DIR / "todo-diablo-gate.sh"
    if not script.is_file():
        return
    # MultiEdit stores content in edits[N].new_string, not at top level
    edits = tool_input.get("edits")
    if isinstance(edits, list):
        new_content = "\n".join(
            e.get("new_string", "") for e in edits if isinstance(e, dict)
        )
    else:
        new_content = tool_input.get("new_string") or tool_input.get("content") or ""
    try:
        proc = subprocess.run(
            ["bash", str(script), file_path, new_content],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=15,
        )
    except Exception as exc:
        log_error(f"R4 todo-diablo-gate subprocess failed: {exc}")
        return  # defensive: allow on ambiguity
    if proc.stdout:
        sys.stdout.write(proc.stdout)
    if proc.stderr:
        sys.stderr.write(proc.stderr)
    if proc.returncode != 0:
        sys.exit(proc.returncode)


# ---------------------------------------------------------------- bash rules


def _extract_commit_message(command: str):
    """Extract commit message from -m "..." / -m '...' / --message=... / heredoc form."""
    if not re.search(r"git(\s+\S+)*?\s+commit\b", command):
        return None
    patterns = [
        r'--message="([^"]*)"',
        r"--message='([^']*)'",
        r"--message=([^\s\"'][^\s]*)",
        r'-m\s+"([^"]*)"',
        r"-m\s+'([^']*)'",
        r"-m\s+([^\s\"'][^\s]*)",
    ]
    msg = None
    for pat in patterns:
        m = re.search(pat, command)
        if m:
            msg = m.group(1)
            break
    if msg is None:
        return None
    # heredoc form: git commit -m "$(cat <<'EOF' ... EOF)" — message is heredoc body
    if msg.startswith("$(cat"):
        hd = re.search(r"<<-?\s*['\"]?(\w+)['\"]?\n(.*?)\n\1", command, re.DOTALL)
        if hd:
            body = hd.group(2).strip()
            if body:
                return body
        return None  # ambiguous → don't judge
    return msg


def rule_commit_prefix(command: str) -> None:
    """R5: git commit message must carry a taxonomy prefix."""
    msg = _extract_commit_message(command)
    if not msg:
        return
    if COMMIT_PREFIX_RE.match(msg):
        return
    block(
        "=== COMMIT PREFIX REQUIRED ===\n"
        f"Message: {msg}\n"
        "Required prefix: [BACKUP|CHANGE|META|HANDOFF|PROCESS|RULES|SEC|FIX|WIP]\n"
        "See: .claude/rules/workflow.md (commit taxonomy)"
    )


def rule_task_id_validator(command: str, cwd: str) -> None:
    """R6: delegate to task-id-validator.sh (argv: command)."""
    if not re.search(r"git(\s+\S+)*?\s+commit\b", command):
        return
    script = HOOKS_DIR / "task-id-validator.sh"
    if not script.is_file():
        return
    try:
        proc = subprocess.run(
            ["bash", str(script), command],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=15,
        )
    except Exception as exc:
        log_error(f"R6 task-id-validator subprocess failed: {exc}")
        return  # defensive: allow on ambiguity
    if proc.stdout:
        sys.stdout.write(proc.stdout)
    if proc.stderr:
        sys.stderr.write(proc.stderr)
    if proc.returncode != 0:
        sys.exit(proc.returncode)


def rule_destructive_shell(command: str) -> None:
    """R7: block destructive shell commands + broad git add."""
    if DESTRUCTIVE_SHELL_RE.search(command):
        block(
            "[BLOCKED] Destructive shell command detected.\n"
            f"Command: {command}\n"
            "If this is intentional, ask the user to run it manually."
        )
    if BROAD_GIT_ADD_RE.search(command):
        if os.environ.get("CLAUDE_ALLOW_BROAD_ADD", "") == "1":
            return
        block(
            "[BLOCKED] Broad git add detected (git add -A / --all / .).\n"
            f"Command: {command}\n"
            "Stage files explicitly — broad git add has leaked secrets before.\n"
            "Bypass (after explicit user approval): CLAUDE_ALLOW_BROAD_ADD=1"
        )


def rule_destructive_sql(command: str) -> None:
    """R8: block destructive SQL — DROP/TRUNCATE and DELETE without WHERE."""
    if DESTRUCTIVE_SQL_RE.search(command):
        block(
            "[BLOCKED] Destructive SQL detected.\n"
            f"Command: {command}\n"
            "If this is intentional, ask the user to run it manually."
        )
    if DELETE_NO_WHERE_RE.search(command) and not re.search(
        r"\bWHERE\b", command, re.IGNORECASE
    ):
        block(
            "[WARN] DELETE without WHERE detected — will erase entire table.\n"
            f"Command: {command}\n"
            "Blocked. Add a WHERE clause or run manually."
        )


def rule_tests_prod_db(command: str) -> None:
    """R11 (F-161): block integration tests aimed at a non-test database.

    Best-effort client-side layer — inspects the command string only (env exported
    earlier is invisible). The real wall is server-side: a test DB role with no
    CONNECT on prod. Bypass: CLAUDE_ALLOW_DESTRUCTIVE=1.
    """
    if os.environ.get("CLAUDE_ALLOW_DESTRUCTIVE", "") == "1":
        return
    if GIT_COMMIT_RE.search(command):
        return  # commit message quoting these terms is text, not a test run
    if not INTEG_TEST_RE.search(command):
        return
    for _var, url in DB_URL_ASSIGN_RE.findall(command):
        dbname = url.rsplit("/", 1)[-1].split("?")[0].strip("'\"")
        if "test" not in dbname.lower():
            block(
                f"[BLOCKED] Integration tests target a non-test DB via {_var} "
                f"({dbname!r}).\n"
                f"Command: {command}\n"
                "F-161: an inherited prod DB URL let a test teardown DROP prod schema.\n"
                "Use a *test* DB (name containing 'test').\n"
                "Bypass (after explicit user approval): CLAUDE_ALLOW_DESTRUCTIVE=1"
            )
    # pytest inside a compose/prod container without an explicit test-DB URL in the
    # SAME command = container inherits the image's prod DB env (the F-161 vector).
    if CONTAINER_RUN_RE.search(command) and "pytest" in command and not (
        TEST_DB_URL_ASSIGN_RE.search(command)
    ):
        block(
            "[BLOCKED] pytest inside a container without an explicit "
            "TEST_*_URL=…test… in the same command.\n"
            f"Command: {command}\n"
            "F-161: the container inherits the image's PROD DB env; a test teardown "
            "wiped prod schema this way.\n"
            "Pass TEST_DATABASE_URL(=…test…) explicitly, or run tests locally.\n"
            "Bypass (after explicit user approval): CLAUDE_ALLOW_DESTRUCTIVE=1"
        )


def rule_volume_wipe(command: str) -> None:
    """R12: block docker volume destruction — `compose down -v`, `volume rm/prune`.

    These erase databases without any SQL appearing in the command string, locally
    or via ssh (the whole string is scanned, remote payload included).
    Bypass: CLAUDE_ALLOW_DESTRUCTIVE=1.
    """
    if os.environ.get("CLAUDE_ALLOW_DESTRUCTIVE", "") == "1":
        return
    if GIT_COMMIT_RE.search(command):
        return
    if VOLUME_WIPE_RE.search(command):
        block(
            "[BLOCKED] Docker volume destruction detected (down -v / volume rm|prune) "
            "— this erases databases.\n"
            f"Command: {command}\n"
            "If intentional, ask the user to run it manually.\n"
            "Bypass (after explicit user approval): CLAUDE_ALLOW_DESTRUCTIVE=1"
        )


def _first_oversize(path: Path):
    """First file >1MB at path (recursing into dirs, skipping .git). None if OK.

    Returns (Path, size_bytes). Never raises — any FS error means 'no hit'.
    """
    try:
        if path.is_file():
            size = path.stat().st_size
            if size > SIZE_GUARD_LIMIT_BYTES:
                return path, size
        elif path.is_dir():
            for root, dirs, files in os.walk(path):
                dirs[:] = [d for d in dirs if d != ".git"]
                for name in files:
                    fp = Path(root) / name
                    try:
                        size = fp.stat().st_size
                    except OSError:
                        continue
                    if size > SIZE_GUARD_LIMIT_BYTES:
                        return fp, size
    except Exception:
        pass
    return None


def rule_size_guard(command: str, cwd: str) -> None:
    """R9: block `git add` / `git commit` involving files >1MB.

    git add  → check the listed path arguments (dirs walked, .git skipped).
    git commit → check staged files (`git diff --cached --name-only`).
    Nonexistent paths and flags are ignored; any error → fail-open.
    Bypass: CLAUDE_ALLOW_BIG_FILE=1.
    """
    if os.environ.get("CLAUDE_ALLOW_BIG_FILE", "") == "1":
        return
    candidates = []
    m = GIT_ADD_ARGS_RE.search(command)
    if m:
        try:
            tokens = shlex.split(m.group(1))
        except ValueError:
            tokens = m.group(1).split()
        for tok in tokens:
            if not tok or tok.startswith("-"):
                continue  # flags and `--` separator carry no path to size-check
            p = Path(tok)
            if not p.is_absolute():
                p = Path(cwd) / p
            candidates.append(p)
    if GIT_COMMIT_RE.search(command):
        git_root = _git(["rev-parse", "--show-toplevel"], cwd)
        staged = _git(["diff", "--cached", "--name-only"], cwd)
        if git_root and staged:
            for name in staged.splitlines():
                name = name.strip()
                if name:
                    candidates.append(Path(git_root) / name)
    for p in candidates:
        hit = _first_oversize(p)
        if hit:
            fp, size = hit
            mb = size / (1024 * 1024)
            block(
                f"[SIZE GUARD] {fp} is {mb:.1f} MB (>1MB). "
                "Large files leak secrets/bloat history. "
                "Bypass: CLAUDE_ALLOW_BIG_FILE=1"
            )


def _log_once_per_day(message: str) -> None:
    """log_error, but at most once per UTC day for the same message."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    try:
        log_file = project_dir() / ".claude" / "session-log" / "hook-errors.log"
        if log_file.is_file():
            with open(log_file, encoding="utf-8") as fh:
                for line in fh:
                    if line.startswith(today) and message in line:
                        return
    except Exception:
        pass
    log_error(message)


_GITLEAKS_UNSUPPORTED_RE = re.compile(
    r"unknown (command|flag|shorthand)", re.IGNORECASE
)


def rule_gitleaks_gate(command: str, cwd: str) -> None:
    """R10: before git commit — scan staged changes with gitleaks, if installed.

    Tries `gitleaks protect --staged` (pre-8.19 form, still a hidden alias in
    newer versions), falls back to `gitleaks git --staged` (8.19+ form) when
    the subcommand/flags are unsupported. Findings → block. gitleaks missing →
    silent skip with one hook-errors.log line per day. Timeout/errors → fail-open.
    """
    if not GIT_COMMIT_RE.search(command):
        return
    gitleaks = shutil.which("gitleaks")
    if not gitleaks:
        _log_once_per_day(
            "R10 gitleaks not installed — staged secret scan skipped"
        )
        return
    git_root = _git(["rev-parse", "--show-toplevel"], cwd)
    if not git_root:
        return  # not a repository → nothing staged to scan
    variants = [
        ["protect", "--staged", "--no-banner", "--exit-code", "1"],
        ["git", "--staged", "--no-banner", "--exit-code", "1", "."],
    ]
    for args in variants:
        try:
            proc = subprocess.run(
                [gitleaks] + args,
                cwd=git_root,
                capture_output=True,
                text=True,
                timeout=15,
            )
        except subprocess.TimeoutExpired:
            log_error("R10 gitleaks timed out (15s) — fail-open")
            return
        except Exception as exc:
            log_error(f"R10 gitleaks subprocess failed: {exc}")
            return
        output = (proc.stderr or "") + (proc.stdout or "")
        if proc.returncode == 0:
            return  # clean
        if _GITLEAKS_UNSUPPORTED_RE.search(output):
            continue  # this gitleaks version lacks the subcommand/flag → next form
        if proc.returncode == 1:
            head = [ln for ln in output.splitlines() if ln.strip()][:10]
            block(
                "[GITLEAKS] Secrets detected in staged changes — commit blocked.\n"
                + "\n".join(head)
                + "\nUnstage and remove the secret(s), then commit again."
                " Details: gitleaks " + " ".join(args) + " -v (run from repo root)."
            )
        # any other exit code = gitleaks internal error → fail-open
        log_error(f"R10 gitleaks exit {proc.returncode}: {output.strip()[:200]}")
        return
    log_error("R10 gitleaks: no supported staged-scan subcommand — skipped")


# ---------------------------------------------------------------------- main


def dispatch(raw_stdin: str) -> None:
    data = json.loads(raw_stdin)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input") or {}
    if not isinstance(tool_input, dict):
        return
    cwd = data.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()

    if tool_name in ("Edit", "Write", "NotebookEdit"):
        file_path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
        if not file_path:
            return
        rule_config_protection(file_path)         # R2 (R1 backup-gate removed)
        rule_security_reminder(file_path, raw_stdin)  # R3
        rule_todo_diablo_gate(file_path, tool_input, cwd)  # R4
    elif tool_name == "Bash":
        command = tool_input.get("command") or ""
        if not command:
            return
        rule_commit_prefix(command)               # R5
        rule_task_id_validator(command, cwd)      # R6
        rule_destructive_shell(command)           # R7
        rule_destructive_sql(command)             # R8
        rule_size_guard(command, cwd)             # R9
        rule_gitleaks_gate(command, cwd)          # R10
        rule_tests_prod_db(command)               # R11 (F-161)
        rule_volume_wipe(command)                 # R12


def main() -> None:
    # argv[1] = event name; only PreToolUse rules implemented, others no-op.
    event = sys.argv[1] if len(sys.argv) > 1 else "PreToolUse"
    if event != "PreToolUse":
        sys.exit(0)
    try:
        raw_stdin = sys.stdin.read()
    except Exception as exc:
        log_error(f"stdin read failed: {exc}")
        sys.exit(0)
    try:
        dispatch(raw_stdin)
    except SystemExit:
        raise  # deliberate block (exit 2) or subprocess passthrough
    except json.JSONDecodeError as exc:
        log_error(f"stdin JSON parse error: {exc}")
        sys.exit(0)  # fail-open
    except Exception as exc:
        log_error(f"internal error: {type(exc).__name__}: {exc}")
        sys.exit(0)  # fail-open
    sys.exit(0)


if __name__ == "__main__":
    main()
