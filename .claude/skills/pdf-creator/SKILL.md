---
name: pdf-creator
description: "Convert markdown reports to A4 PDF with Russian / Ukrainian / English text rendering via weasyprint. Designed for delivering final-report.md and matrix.md to stakeholders in printable form. Triggers: 'make PDF', 'render to PDF', 'PDF version', 'send the report as PDF'."
---

# PDF Creator

Convert any markdown file in this framework to a well-formatted A4 PDF suitable for stakeholders. Supports Russian, Ukrainian, and English.

Adapted from the upstream `pdf-creator` skill (originally focused on Chinese typography). This copy replaces the CJK font stack with system fonts that cover Cyrillic and Latin, since this framework targets three languages only.

## Supported languages

| Language | `--lang` value | Font coverage |
|----------|----------------|---------------|
| Russian  | `ru` (default) | Cyrillic — Times/Helvetica/SF Mono all have full Cyrillic glyphs |
| Ukrainian | `uk` | Cyrillic + extras (є, і, ї, ґ) — same font coverage as Russian |
| English  | `en` | Latin — trivial |

The `--lang` flag sets the HTML `lang` attribute; it affects hyphenation hints but not glyph rendering. Glyph rendering is driven entirely by the font stack.

## Quick start

**ВАЖНО для macOS:** всегда запускай скрипт с префиксом `DYLD_LIBRARY_PATH=/opt/homebrew/lib`, иначе `uv` запустит Python в изолированном окружении которое не видит libgobject/libpango из Homebrew.

Single file (default: Russian):

```bash
DYLD_LIBRARY_PATH=/opt/homebrew/lib uv run --with weasyprint --with markdown \
    .claude/skills/pdf-creator/scripts/md_to_pdf.py \
    specs/analysis/<slug>/final-report.md \
    specs/analysis/<slug>/final-report.pdf
```

Single file, Ukrainian:

```bash
DYLD_LIBRARY_PATH=/opt/homebrew/lib uv run --with weasyprint --with markdown \
    .claude/skills/pdf-creator/scripts/md_to_pdf.py \
    --lang uk specs/analysis/<slug>/final-report.md
```

Single file, English:

```bash
DYLD_LIBRARY_PATH=/opt/homebrew/lib uv run --with weasyprint --with markdown \
    .claude/skills/pdf-creator/scripts/md_to_pdf.py \
    --lang en specs/analysis/<slug>/final-report.md
```

Batch (whole analysis folder):

```bash
DYLD_LIBRARY_PATH=/opt/homebrew/lib uv run --with weasyprint --with markdown \
    .claude/skills/pdf-creator/scripts/batch_convert.py \
    specs/analysis/<slug>/*.md \
    --output-dir specs/analysis/<slug>/pdf \
    --lang ru
```

## macOS environment setup (if weasyprint fails on import)

Если при первом запуске видишь ошибку `cannot load library 'libgobject-2.0.0'` или `libpango`:

1. Установи системные библиотеки:
   ```bash
   brew install pango gdk-pixbuf libffi
   ```
2. Убедись что `DYLD_LIBRARY_PATH=/opt/homebrew/lib` присутствует в команде запуска (см. Quick start выше).

Если используешь Linux — `DYLD_LIBRARY_PATH` не нужен, это macOS-specific переменная; на Linux библиотеки подхватываются через `LD_LIBRARY_PATH` или через системный dynamic linker напрямую.

## Fonts used

Default font stack (all pre-installed on macOS; Linux fallbacks included):

| Role | Primary | Fallbacks |
|------|---------|-----------|
| Body (serif) | Times New Roman | Liberation Serif, DejaVu Serif, Noto Serif |
| Headings (sans) | Helvetica Neue | Helvetica, Arial, Liberation Sans, DejaVu Sans, Noto Sans |
| Code (mono) | SF Mono | Menlo, Monaco, DejaVu Sans Mono, Liberation Mono |

All primaries have full Cyrillic coverage. If you see boxes instead of letters, install Noto:

```bash
brew install --cask font-noto-serif font-noto-sans
```

## Output spec

- Page: A4 (210 × 297 mm)
- Margins: 2.5 cm top/bottom, 2 cm left/right
- Body: 12 pt, line-height 1.8, justified
- Headings: bold sans, hierarchy 18/14/12 pt
- Code blocks: 10 pt, light grey background
- Tables: full-width, bordered, 10 pt
- Page numbers: "N / Total" in bottom center, 9 pt grey

## Markdown features supported

- **TOC:** вставь `[TOC]` в markdown — pdf-creator автоматически сгенерирует оглавление с номерами страниц (leader-dots до номера). Title подставляется по `--lang` (ru/uk: "Оглавление", en: "Table of Contents").
- **Footnotes:** используй markdown footnote syntax `[^1]` inline и `[^1]: definition` в любом месте документа. В PDF рендерится как внизу-страничные сноски со стрелкой "↩" для возврата.
- **Hyperlinks:** стандартный markdown `[text](url)` — рендерится как кликабельная ссылка в PDF с подчёркиванием (цвет `#1a5490`).
- **Internal anchors:** заголовки автоматически получают slug-id, можно ссылаться `[Section 3](#section-3)`.
- **Tables:** GFM-стиль `| col | col |`.
- **Fenced code:** `` ``` `` блоки с опциональным lang-hint.
- **attr_list:** можно добавлять классы/id к элементам через `{: .class #id}`.

## When to use this in the analyze-spec pipeline

This skill is **optional** and runs at Step 9 of `/analyze-spec` only if the user asks for PDF output.

Use it when:
- The final report will be sent to a non-technical stakeholder who prefers PDF.
- Archival / legal purposes (signed deliverables).
- Printing a hard copy.

Do NOT use it when:
- The report is read only in the terminal / editor — markdown is faster to iterate on.
- You're still iterating on the analysis. Regenerate only after Diablo's verdict is final.

## Common files to render

Typical recipe after `/analyze-spec` completes:

```bash
# Stakeholder-facing deliverable only:
uv run --with weasyprint --with markdown .claude/skills/pdf-creator/scripts/md_to_pdf.py \
    specs/analysis/<slug>/final-report.md

# Full audit package (one PDF per file):
uv run --with weasyprint --with markdown .claude/skills/pdf-creator/scripts/batch_convert.py \
    specs/analysis/<slug>/final-report.md \
    specs/analysis/<slug>/matrix.md \
    specs/analysis/<slug>/devil-spec.md \
    specs/analysis/<slug>/devil-verification.md \
    --output-dir specs/analysis/<slug>/pdf
```

## Troubleshooting

**Boxes instead of letters** → font fallback failed. Install Noto fonts: `brew install --cask font-noto-serif font-noto-sans`.

**`weasyprint` import error** → use `uv run --with weasyprint --with markdown` as shown. Raw `python md_to_pdf.py` fails unless deps are in the global env.

**Huge file size (>5 MB)** → large embedded images. Strip or resize before conversion.

**Tables overflow** — CSS forces `table-layout: fixed` and `word-break: break-all`. If still clipping, shorten cells; A4 width is the hard limit.

**Ukrainian-specific glyphs display wrong** → all `ru`-capable fonts above cover `uk` extras (є, і, ї, ґ). If not rendering, check that Times New Roman / Helvetica aren't overridden by a custom system fallback.

## Credit

Original author: upstream `pdf-creator` skill (weasyprint-based Chinese-document automation). This copy drops the CJK font stack, replaces with Cyrillic/Latin primaries, and adds a `--lang` flag. Scripts are otherwise functionally identical.
