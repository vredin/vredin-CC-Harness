# Claude Project Harness (template v3.2.0)

**English** below · [**Українська**](#українська) нижче

> **Start here / Почніть звідси:**
> **`/setup`** — one-time wizard (language, knowledge-base backend, health check, schedules). Run it FIRST.
> **`/911`** — cheatsheet of all commands when you forget what exists (`/911-full` — complete listing).

---

## What this is

A batteries-included configuration harness for Claude Code: slash commands, skills, subagents, deterministic safety hooks, and a memory system — everything preconfigured so an AI-assisted project runs with engineering discipline instead of vibe coding.

## Purpose

The harness solves four chronic problems of AI-assisted development:

1. **Silent scope loss** — tasks mentioned in chat evaporate. Here every task becomes a spec file on disk, gated by an adversarial critic before it enters the backlog.
2. **Confident hallucination** — rates, fees and policies get invented. Business rules live in `docs/RULES.md`; the assistant must cite a rule or refuse.
3. **Unsafe automation** — 11 deterministic PreToolUse hook rules block destructive shell commands, unprefixed commits, secrets in staged changes, oversized files, prod-DB test runs, unscoped test suites and more — mechanically, not by trusting the model.
4. **Amnesia between sessions** — file-based memory (fails, patterns, decisions, handoff files) survives context compaction; a shared knowledge base syncs lessons across projects.

## Quick start

1. Put this directory somewhere permanent, open it in Claude Code.
2. Run **`/setup`** — pick language, knowledge-base backend (Outline / GitHub repo / local vault), verify health.
3. To scaffold a NEW project from the template: **`/init-project /path/to/new-project`**
4. Day-to-day you mostly need four commands: `/todo`, `/orchestrate`, `/general`, `/rule`.

## Command reference

### Daily core

| Command | What it does |
|---|---|
| `/todo [add <text>] [start T-NNN] [done T-NNN] [list]` | Spec-first task management. `add` runs a size triage, an interview (grill), writes a spec file, and passes an adversarial review gate before the task enters `docs/TASK.md`. `list` shows the backlog in plain language. |
| `/orchestrate` | Autonomous backlog execution: picks tasks, writes tests first, implements, runs static checks, adversarial review, commits. Stops only on blockers or an empty backlog. |
| `/general <question>` | Evidence-first Q&A about your codebase/infra. Reads code, the knowledge base, read-only DB. Never speculates; shows sources. |
| `/rule <statement>` | Capture a business rule (rate, fee, formula, policy) into `docs/RULES.md` as an R-NNN row. The assistant cites these instead of inventing numbers. |

### Setup & scaffolding

| Command | What it does |
|---|---|
| `/setup` | Wizard: fresh install / reconfigure MCP / verify health / migrate v2→v3 / register schedules. |
| `/init-project [/path/to/new-project]` | Interactive scaffold of a new project from this template: collects stack/deploy info, copies structure, replaces placeholders, initializes git. |
| `/911` · `/911-full` | Short / complete command cheatsheet. |

### Greenfield: idea → build

| Command | What it does |
|---|---|
| `/market-research <idea>` | Jobs-To-Be-Done research of a NEW idea. Verdict GO / NARROW / PIVOT + segments, market size, competitors-by-job. |
| `/value-prop <segment>` | Strongest testable value proposition + RICE ranking + riskiest-assumption test cards. |
| `/design-system <goal>` | Goal with no formal spec → full system-design report, build-vs-buy, min/mid/max scope. |
| `/analyze-spec <file \| pasted text> [--pdf]` | Raw spec → normalized spec, gap analysis, decision matrices, verification, final report. |
| `/product-requirements <segment+value>` | Build-ready PRD with ~90% of edge cases. |
| `/intent <vague idea>` | Compact shortcut: idea → PRD via research + adversarial review. |
| `/decompose <PRD-NNN \| requirements doc>` | PRD → Architecture (ADRs) → Epics → Tasks, four adversarial gates, traceability matrix. |
| `/diagnose` | For a LIVE product with users: where the chain-to-profit breaks, growth moves, riskiest assumptions. |
| `/advisor` | Conversational product advisor; routes to the right skill. Related: `/ce-ideate` (idea generation), `/analyze-interviews`, `/go-to-market` (launch copy). |

### Build & fix

| Command | What it does |
|---|---|
| `/fix <bug description \| #issue>` | Disciplined bug fix: prior-knowledge search, root cause with evidence, failing test FIRST, fix, green test, same-bug-elsewhere sweep, security check, adversarial review, lesson file. Deploys automatically when deploy is configured. |
| `/quick-plan <task>` | Lightweight plan document for trivial work (no ceremony). |
| `/test [backend\|frontend\|e2e\|all\|<pattern>]` | Run the test suite or a subset. |
| `/deploy` | Production deploy pipeline: pre-flight, backup gate (no migration without a fresh verified backup), secrets delivery, build, migrations, live verification via /health SHA, tests, auto-rollback on post-migration failure. |
| `/canary <production_url>` | Post-deploy probe: critical routes, JS errors, response-time drift vs saved baseline. |

### Review & audit

| Command | What it does |
|---|---|
| `/review [scope] [--threshold N]` | Full review pipeline: deterministic static pre-pass → core reviewer → conditional security agent → E2E gate → inline confidence scoring (default ≥80) → blind adversarial verification of CRITICAL/HIGH findings. |
| `/da [spec\|plan\|impl\|review] [target]` | Direct invocation of the adversarial critic (Diablo). Verdicts: BLOCKED / FIX FIRST / PROCEED WITH CAUTION / ACCEPTABLE, each with a next step. |
| `/gaps [missing\|modern\|both\|vs-prd\|domain\|tests\|improve\|<path>]` | Service-level audit. `missing` = vs production-grade checklist; `modern` = vs current practices; `vs-prd` = promised-but-absent; `domain` = business-logic correctness + robustness interrogation; `tests` = do the tests actually hunt bugs (works with NO docs); `improve` = offensive mode: proposes business/feature moves and studies competitors. Bare `/gaps` asks which mode you want. |
| `/global-audit [scope] [--quick]` | Breadth-first parallel audit: 11 read-only lenses (security, state-sync, data lifecycle, performance, concurrency, …), FMEA-scored, blind-verified, one report. Read-only. |
| `/improve-arch [path]` | Architecture deepening (Ousterhout-style) with ADR generation. |
| `/plan-devex-review` | For APIs/CLIs/SDKs consumed by other developers: scores 7 DX dimensions (install, time-to-hello-world, errors, docs, …). |
| `/council <question>` | Two-model parallel deliberation for architecture-level decisions. |

#### The 11 audit lenses of `/global-audit`

Each lens is an independent read-only reviewer looking at the whole service from one angle:

1. **Layers** — does data actually flow correctly through every layer (route → service → DB → response), or do layers bypass/duplicate each other.
2. **Security / IDOR** — can user A reach user B's objects by swapping an id; auth checks at every resource boundary, not just at login.
3. **State sync** — places where two sources of truth can diverge (cache vs DB, frontend state vs server, denormalized copies).
4. **Errors / empty / offline** — what the user actually sees on failure, empty data, or lost connectivity: readable messages vs blank screens and `undefined`.
5. **Data lifecycle** — creation → mutation → archival → deletion: orphaned records, missing cascades, soft-delete leaks, retention.
6. **Navigation** — dead ends, unreachable screens, back-button traps, deep links that break.
7. **Invariants / trust fields** — values that must always hold (balances non-negative, totals = sum of parts) and fields the client can tamper with but the server trusts.
8. **Performance** — N+1 queries, missing indexes, oversized payloads, unbounded lists.
9. **Concurrency / races** — double-submit, parallel edits, lost updates, non-idempotent retries.
10. **Correctness vs business rules** — money/date/metric/funnel computations cross-checked against `docs/RULES.md`: wrong rate, `<=` vs `<`, timezone-shifted dates.
11. **Robustness (adversarial interrogation)** — bad/empty/wrong-type inputs, retry idempotency, mid-flow cancellation, expired tokens/links, flooding without rate limits.

Findings are deduplicated, FMEA-scored (severity × occurrence × detectability), CRITICAL/HIGH ones are blind-verified by an independent agent, and everything lands in one report. `--quick` runs the core 6 lenses.


### Knowledge & docs

| Command | What it does |
|---|---|
| `/docs [sync\|audit]` | Weekly drift detection between docs and code; `sync` publishes to the knowledge base. |
| `/report [period]` | Progress report (done / in progress / blocked). Designed for a daily schedule. |
| `/triage` | Morning discovery: CI failures, open issues, TODO/FIXME, stale items → seeds the inbox as IDEA-N candidates. Read-only. |
| `/self-audit [--global]` | Weekly process improvement: recurring failure patterns → diff-ready fixes to rules/commands. `--global` aggregates across projects. |
| `/revise-claude-md` | Capture session learnings into CLAUDE.md at session end. |

### UI / design

| Command | What it does |
|---|---|
| `/ui <plain words>` | Single front door for ALL UI work. Classifies intent and routes: explore / build / polish / critique / reason / reference. Includes a 44-rule deterministic anti-slop detector. |
| `/ui-explore <product> [--quick]` | 2-3 distinct mockup directions → detector pass → adversarial critique → winner persisted to `design-system/MASTER.md`. |

### Claude Code built-ins worth knowing

| Command | What it does |
|---|---|
| `/goal <measurable condition>` | Loop until a condition provably holds. |
| `/loop "<cron>" /command` | Schedule any command (e.g. daily `/report`, weekly `/docs audit`). |
| `/code-review [level\|ultra]` | Built-in diff review; `ultra` = deep multi-agent cloud review. |

## Safety hooks (mechanical, not model-trusted)

11 PreToolUse rules dispatch on every tool call: commit-message taxonomy, task-id validation, destructive-shell blocking (`rm -rf`, `reset --hard`, force push, broad `git add`), destructive SQL, secrets scan of staged changes (gitleaks), >1MB file guard, test-vs-prod-DB wall, docker volume-wipe gate, config-file protection. Hermetic test stand: `bin/test-hooks.sh` (42 fixtures). CI runs hooks, memory lint and a static gate on every push.

## Memory system

`docs/RULES.md` (business rules R-NNN) · `docs/FAILS.md` + `docs/fails/` (one file per lesson F-NNN) · `docs/PATTERNS.md` (reusable solutions) · `docs/KNOWLEDGE.md` (architecture decisions) · `docs/CONTEXT.md` (domain glossary) · `docs/adr/` (immutable decision records) · `docs/handoff.md` (session-to-session baton, auto-rescued before context compaction).

## Requirements

Claude Code CLI (recent), git, python3, bash. Optional: gitleaks, ruff/mypy/bandit/vulture/radon (static gate degrades gracefully), an Outline instance or a GitHub repo for the shared knowledge base.

## License / provenance

Vendored third-party skills keep their upstream licenses and pinned commit SHAs in file headers (anthropics plugins, Nutlope/hallmark MIT, and others — see headers).

---

# Українська

> **Почніть звідси:**
> **`/setup`** — одноразовий майстер (мова, бекенд бази знань, перевірка здоров'я, розклади). Запустіть ПЕРШИМ.
> **`/911`** — шпаргалка всіх команд, коли забули, що існує (`/911-full` — повний перелік).

## Що це

Готова обв'язка для Claude Code: слеш-команди, навички, субагенти, детерміновані запобіжні хуки та система пам'яті — усе налаштовано, щоб проєкт з ІІ-асистентом працював за інженерною дисципліною, а не «як вийде, аби працювало».

## Мета

Обв'язка закриває чотири хронічні проблеми ІІ-розробки:

1. **Тихе зникнення задач** — згадане в чаті випаровується. Тут кожна задача стає файлом-специфікацією на диску і проходить ворота адверсарного критика, перш ніж потрапити в беклог.
2. **Впевнені вигадки** — тарифи, комісії та політики вигадуються. Бізнес-правила живуть у `docs/RULES.md`; асистент або цитує правило, або відмовляється.
3. **Небезпечна автоматизація** — 11 детермінованих хук-правил блокують руйнівні shell-команди, коміти без префіксів, секрети у staged-змінах, завеликі файли, тести на бойовій БД, повний тестовий прогін без фокуса — механічно, без довіри до моделі.
4. **Амнезія між сесіями** — файлова пам'ять переживає стиснення контексту; спільна база знань синхронізує уроки між проєктами.

## Швидкий старт

1. Покладіть цю теку в постійне місце, відкрийте в Claude Code.
2. Запустіть **`/setup`** — мова, бекенд бази знань (Outline / GitHub / локальне сховище), перевірка здоров'я.
3. Новий проєкт із шаблону: **`/init-project /шлях/до/проєкту`**
4. Щодня потрібні переважно чотири команди: `/todo`, `/orchestrate`, `/general`, `/rule`.

## Довідник команд

### Щоденне ядро

| Команда | Що робить |
|---|---|
| `/todo [add <текст>] [start T-NNN] [done T-NNN] [list]` | Задачі через специфікацію. `add` — сортування за розміром, інтерв'ю, файл-спека, ворота адверсарної перевірки — і лише тоді задача потрапляє в `docs/TASK.md`. `list` — беклог простою мовою. |
| `/orchestrate` | Автономне виконання беклогу: бере задачі, спочатку тести, потім реалізація, статичні перевірки, адверсарний огляд, коміт. Зупиняється лише на блокерах чи порожньому беклозі. |
| `/general <питання>` | Відповіді про кодову базу/інфраструктуру на доказах: читає код, базу знань, БД у режимі читання. Без спекуляцій; показує джерела. |
| `/rule <твердження>` | Фіксує бізнес-правило (тариф, комісію, формулу, політику) в `docs/RULES.md` як рядок R-NNN. Асистент цитує їх замість вигадування чисел. |

### Налаштування і каркас

| Команда | Що робить |
|---|---|
| `/setup` | Майстер: перша інсталяція / переналаштування MCP / перевірка здоров'я / міграція v2→v3 / розклади. |
| `/init-project [/шлях/до/проєкту]` | Інтерактивний каркас нового проєкту з шаблону: стек і деплой, копіювання структури, заміна плейсхолдерів, ініціалізація git. |
| `/911` · `/911-full` | Коротка / повна шпаргалка команд. |

### Від ідеї до продукту

| Команда | Що робить |
|---|---|
| `/market-research <ідея>` | Дослідження НОВОЇ ідеї через Jobs-To-Be-Done. Вердикт GO / NARROW / PIVOT + сегменти, розмір ринку, конкуренти-за-роботою. |
| `/value-prop <сегмент>` | Найсильніша перевірювана ціннісна пропозиція + RICE-рейтинг + картки тесту найризиковішого припущення. |
| `/design-system <ціль>` | Ціль без формального ТЗ → повний звіт системного дизайну, build-vs-buy, мін/сер/макс обсяг. |
| `/analyze-spec <файл \| текст> [--pdf]` | Сире ТЗ → нормалізована спека, аналіз прогалин, матриці рішень, верифікація, фінальний звіт. |
| `/product-requirements <сегмент+цінність>` | Готовий до розробки PRD з ~90% крайніх випадків. |
| `/intent <сира ідея>` | Компактний шлях: ідея → PRD через дослідження + адверсарний огляд. |
| `/decompose <PRD-NNN \| документ вимог>` | PRD → Архітектура (ADR) → Епіки → Задачі, четверо воріт критика, матриця простежуваності. |
| `/diagnose` | Для ЖИВОГО продукту з користувачами: де рветься ланцюг до прибутку, ходи зростання, хиткі припущення. |
| `/advisor` | Розмовний продуктовий радник; маршрутизує до потрібної навички. Поруч: `/ce-ideate`, `/analyze-interviews`, `/go-to-market`. |

### Розробка і виправлення

| Команда | Що робить |
|---|---|
| `/fix <опис бага \| #issue>` | Дисциплінований фікс: пошук у базі уроків, корінна причина з доказами, СПОЧАТКУ падаючий тест, фікс, зелений тест, пошук того ж класу бага по проєкту, безпекова перевірка, адверсарний огляд, файл-урок. Деплой автоматичний, якщо налаштовано. |
| `/quick-plan <задача>` | Легкий план для тривіальної роботи (без церемоній). |
| `/test [backend\|frontend\|e2e\|all\|<патерн>]` | Тести або підмножина. |
| `/deploy` | Конвеєр бойового деплою: перевірки, ворота бекапу (жодної міграції без свіжого перевіреного бекапу), доставка секретів, збірка, міграції, перевірка живого сервісу за SHA, тести, автовідкат. |
| `/canary <бойовий_url>` | Проба після деплою: критичні маршрути, JS-помилки, дрейф часу відповіді проти бази. |

### Огляд і аудит

| Команда | Що робить |
|---|---|
| `/review [обсяг] [--threshold N]` | Повний конвеєр огляду: статичний прохід → основний рецензент → безпековий агент за потреби → E2E-ворота → оцінка впевненості (типово ≥80) → сліпа адверсарна верифікація CRITICAL/HIGH. |
| `/da [spec\|plan\|impl\|review] [ціль]` | Прямий виклик адверсарного критика (Diablo). Вердикти: BLOCKED / FIX FIRST / PROCEED WITH CAUTION / ACCEPTABLE. |
| `/gaps [missing\|modern\|both\|vs-prd\|domain\|tests\|improve\|<шлях>]` | Аудит сервісу: проти чекліста продакшн-рівня / сучасних практик / обіцяного в PRD / коректності бізнес-логіки / якості тестів (працює БЕЗ доків) / наступальний режим із конкурентами. Гола `/gaps` сама запитає режим. |
| `/global-audit [обсяг] [--quick]` | Широкий паралельний аудит: 11 лінз лише-читання, FMEA-оцінка, сліпа верифікація, один звіт. |
| `/improve-arch [шлях]` | Поглиблення архітектури (за Остергаутом) з генерацією ADR. |
| `/plan-devex-review` | Для API/CLI/SDK: оцінка 7 вимірів DX. |
| `/council <питання>` | Паралельна нарада двох моделей для архітектурних рішень. |

#### 11 лінз аудиту `/global-audit`

Кожна лінза — незалежний рецензент лише-читання, що дивиться на весь сервіс під одним кутом:

1. **Шари** — чи справді дані коректно проходять кожен шар (маршрут → сервіс → БД → відповідь), чи шари обходять/дублюють одне одного.
2. **Безпека / IDOR** — чи може користувач А дістати об'єкти користувача Б, підмінивши id; перевірка прав на КОЖНІЙ межі ресурсу, а не лише на вході.
3. **Синхронізація стану** — місця, де два джерела правди можуть розійтися (кеш проти БД, стан фронтенду проти сервера, денормалізовані копії).
4. **Помилки / порожнеча / офлайн** — що реально бачить користувач при збої, порожніх даних чи втраті зв'язку: зрозумілі повідомлення чи білий екран і `undefined`.
5. **Життєвий цикл даних** — створення → зміна → архів → видалення: осиротілі записи, відсутні каскади, витоки м'якого видалення, терміни зберігання.
6. **Навігація** — глухі кути, недосяжні екрани, пастки кнопки «назад», биті глибокі посилання.
7. **Інваріанти / поля довіри** — значення, що мусять триматися завжди (баланс невід'ємний, сума = сума частин), і поля, які клієнт може підробити, а сервер їм вірить.
8. **Продуктивність** — N+1 запити, відсутні індекси, роздуті відповіді, необмежені списки.
9. **Конкурентність / перегони** — подвійне надсилання, паралельні правки, загублені оновлення, неідемпотентні повтори.
10. **Коректність проти бізнес-правил** — обчислення грошей/дат/метрик/воронок звірені з `docs/RULES.md`: не той тариф, `<=` замість `<`, зсунуті часовим поясом дати.
11. **Стійкість (адверсарний допит)** — погані/порожні/не того типу входи, ідемпотентність повторів, скасування посеред процесу, прострочені токени/посилання, флуд без обмежень частоти.

Знахідки дедуплікуються, оцінюються за FMEA (тяжкість × частота × виявлюваність), CRITICAL/HIGH сліпо перевіряє незалежний агент, усе — в один звіт. `--quick` — базові 6 лінз.


### Знання і документи

| Команда | Що робить |
|---|---|
| `/docs [sync\|audit]` | Щотижневе виявлення дрейфу документів проти коду; `sync` публікує в базу знань. |
| `/report [період]` | Звіт прогресу (зроблено / в роботі / заблоковано). |
| `/triage` | Ранковий збір: падіння CI, issues, TODO/FIXME, застряглі пункти → кандидати IDEA-N. Лише читання. |
| `/self-audit [--global]` | Щотижневе покращення процесу: повторювані патерни збоїв → готові правки правил/команд. |
| `/revise-claude-md` | Зафіксувати уроки сесії в CLAUDE.md наприкінці роботи. |

### UI / дизайн

| Команда | Що робить |
|---|---|
| `/ui <простими словами>` | Єдині вхідні двері для ВСІЄЇ UI-роботи: дослідити / збудувати / відполірувати / критика / обґрунтування / довідник. Детектор ІІ-шаблонності на 44 правила. |
| `/ui-explore <продукт> [--quick]` | 2-3 напрями макетів → детектор → адверсарна критика → переможець у `design-system/MASTER.md`. |

### Вбудовані команди Claude Code

| Команда | Що робить |
|---|---|
| `/goal <вимірювана умова>` | Цикл, доки умова доказово не виконана. |
| `/loop "<cron>" /команда` | Розклад для будь-якої команди. |
| `/code-review [рівень\|ultra]` | Вбудований огляд дифу; `ultra` — глибокий хмарний огляд. |

## Запобіжні хуки · Система пам'яті · Вимоги

Дзеркально до англійських розділів вище: 11 механічних хук-правил зі стендом на 42 фікстури; файлова пам'ять (RULES / FAILS / PATTERNS / KNOWLEDGE / CONTEXT / adr / handoff); вимоги — свіжий Claude Code CLI, git, python3, bash, опційно gitleaks і статичні аналізатори.
