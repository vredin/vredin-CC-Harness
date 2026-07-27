#!/usr/bin/env python3
"""
Markdown to PDF converter for Russian / Ukrainian / English reports.

Adapted from the pdf-creator skill. Original prioritized Chinese fonts; this
copy uses a font stack that covers Cyrillic (ru, uk) and Latin (en) with
system fonts available on macOS and most Linux distributions.

Usage:
    python md_to_pdf.py input.md output.pdf
    python md_to_pdf.py input.md                     # writes input.pdf
    python md_to_pdf.py --lang uk input.md           # Ukrainian lang attribute
    python md_to_pdf.py --lang en input.md           # English lang attribute

Requirements:
    pip install weasyprint markdown
    (or: uv run --with weasyprint --with markdown md_to_pdf.py ...)

    macOS environment setup (if needed):
    export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
"""

import argparse
import sys
from pathlib import Path

import markdown
from weasyprint import CSS, HTML


SUPPORTED_LANGS = ("ru", "uk", "en")

# Fonts directory: <skill-root>/fonts/  (relative to this script's location)
_FONTS_DIR = Path(__file__).parent.parent / "fonts"


def _build_css(fonts_dir: Path) -> str:
    """Build CSS string with @font-face declarations pointing to local font files."""
    manrope_regular = fonts_dir / "Manrope-Regular.ttf"
    manrope_bold    = fonts_dir / "Manrope-Bold.ttf"
    nunito_regular  = fonts_dir / "NunitoSans-Regular.ttf"
    nunito_bold     = fonts_dir / "NunitoSans-Bold.ttf"
    montserrat_sb   = fonts_dir / "Montserrat-SemiBold.ttf"
    montserrat_b    = fonts_dir / "Montserrat-Bold.ttf"

    # Prefer Nunito Sans for body; fall back to Manrope, then system stack
    if nunito_regular.exists():
        body_family = "'Nunito Sans', 'DejaVu Sans', 'Noto Sans', sans-serif"
        body_faces = f"""
@font-face {{
    font-family: 'Nunito Sans';
    font-style: normal;
    font-weight: 400;
    src: url("{nunito_regular.as_uri()}") format('truetype');
}}
@font-face {{
    font-family: 'Nunito Sans';
    font-style: normal;
    font-weight: 700;
    src: url("{nunito_bold.as_uri()}") format('truetype');
}}"""
    elif manrope_regular.exists():
        body_family = "'Manrope', 'DejaVu Sans', 'Noto Sans', sans-serif"
        body_faces = f"""
@font-face {{
    font-family: 'Manrope';
    font-style: normal;
    font-weight: 400;
    src: url("{manrope_regular.as_uri()}") format('truetype');
}}
@font-face {{
    font-family: 'Manrope';
    font-style: normal;
    font-weight: 700;
    src: url("{manrope_bold.as_uri()}") format('truetype');
}}"""
    else:
        body_family = "'Helvetica Neue', 'Arial', 'DejaVu Sans', 'Noto Sans', sans-serif"
        body_faces = ""

    if montserrat_sb.exists():
        heading_family = f"'Montserrat', {body_family}"
        heading_faces = f"""
@font-face {{
    font-family: 'Montserrat';
    font-style: normal;
    font-weight: 600;
    src: url("{montserrat_sb.as_uri()}") format('truetype');
}}
@font-face {{
    font-family: 'Montserrat';
    font-style: normal;
    font-weight: 700;
    src: url("{montserrat_b.as_uri()}") format('truetype');
}}"""
    else:
        heading_family = body_family
        heading_faces = ""

    font_faces = body_faces + heading_faces

    return font_faces + f"""
/* === Modern report design — inspired by CourtBouillon WeasyPrint samples === */

/* Single accent color, charcoal text, soft greys for structure */
:root {{
    --ink: #1a1a1a;
    --ink-soft: #525252;
    --rule: #d4d4d4;
    --rule-soft: #ebebeb;
    --accent: #0d6e6e;
    --accent-soft: #e8f1f1;
    --highlight-bg: #fafafa;
}}

@page {{
    size: A4;
    margin: 2.2cm 2cm 2cm 2cm;
    @bottom-center {{
        content: counter(page);
        font-family: {body_family};
        font-size: 8.5pt;
        color: var(--ink-soft);
    }}
}}

@page :first {{
    @bottom-center {{ content: ""; }}
}}

body {{
    font-family: {body_family};
    font-size: 10.5pt;
    line-height: 1.55;
    color: var(--ink);
    width: 100%;
    hyphens: auto;
}}

/* === Headings — clear hierarchy via weight + size === */
h1 {{
    font-family: {heading_family};
    font-size: 22pt;
    font-weight: 700;
    color: var(--ink);
    text-align: left;
    margin-top: 0;
    margin-bottom: 0.3em;
    line-height: 1.2;
    border-bottom: 2pt solid var(--accent);
    padding-bottom: 0.4em;
}}

h2 {{
    font-family: {heading_family};
    font-size: 16pt;
    font-weight: 700;
    color: var(--accent);
    margin-top: 2em;
    margin-bottom: 0.6em;
    line-height: 1.25;
    page-break-after: avoid;
}}

h3 {{
    font-family: {heading_family};
    font-size: 12.5pt;
    font-weight: 600;
    color: var(--ink);
    margin-top: 1.4em;
    margin-bottom: 0.4em;
    line-height: 1.3;
    page-break-after: avoid;
}}

h4 {{
    font-family: {heading_family};
    font-size: 11pt;
    font-weight: 600;
    color: var(--ink-soft);
    margin-top: 1em;
    margin-bottom: 0.3em;
    page-break-after: avoid;
}}

p {{
    margin: 0.6em 0;
    text-align: left;
}}

/* === Lists === */
ul, ol {{
    margin: 0.6em 0;
    padding-left: 1.4em;
}}

li {{
    margin: 0.3em 0;
}}

ul li::marker {{
    color: var(--accent);
}}

/* === Tables — modern, no harsh full borders === */
table {{
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
    font-size: 9.5pt;
    table-layout: auto;
    page-break-inside: auto;
}}

thead {{
    display: table-header-group;
}}

tr {{
    page-break-inside: avoid;
}}

th, td {{
    border-bottom: 0.5pt solid var(--rule);
    padding: 8px 10px;
    text-align: left;
    vertical-align: top;
    line-height: 1.4;
    hyphens: auto;
    overflow-wrap: break-word;
}}

th {{
    background-color: var(--accent-soft);
    color: var(--ink);
    font-weight: 600;
    font-size: 9.5pt;
    border-bottom: 1pt solid var(--accent);
    border-top: 1pt solid var(--accent);
    text-align: left;
}}

/* === Horizontal rule === */
hr {{
    border: none;
    border-top: 0.5pt solid var(--rule);
    margin: 1.8em 0;
}}

strong {{
    font-weight: 600;
}}

em {{
    font-style: italic;
    color: var(--ink-soft);
}}

/* === Code === */
code {{
    font-family: 'SF Mono', 'Menlo', 'Monaco', 'DejaVu Sans Mono', 'Liberation Mono', monospace;
    font-size: 9pt;
    background-color: var(--highlight-bg);
    padding: 0.1em 0.35em;
    border-radius: 2px;
    color: var(--ink);
}}

pre {{
    background-color: var(--highlight-bg);
    border-left: 2pt solid var(--accent);
    padding: 0.8em 1em;
    overflow-x: auto;
    font-size: 9pt;
    line-height: 1.5;
    margin: 1em 0;
}}

pre code {{
    background: none;
    padding: 0;
}}

/* === Blockquotes === */
blockquote {{
    border-left: 2pt solid var(--accent);
    background-color: var(--highlight-bg);
    margin: 1em 0;
    padding: 0.5em 1em;
    color: var(--ink-soft);
    font-style: italic;
}}

/* === Hyperlinks — accent color, subtle underline === */
a {{
    color: var(--accent);
    text-decoration: underline;
    text-decoration-thickness: 0.5pt;
    text-underline-offset: 1.5pt;
}}

a:link, a:visited {{ color: var(--accent); }}

/* === Table of Contents — clean, no leader dots === */
.toc {{
    margin: 1em 0 2.5em 0;
    padding: 0;
    border: none;
    background: none;
}}

.toc > .toctitle {{
    display: none;
}}

.toc > ul {{
    list-style: none;
    padding-left: 0;
    margin: 0;
}}

.toc ul ul {{
    list-style: none;
    padding-left: 1.2em;
    margin: 0.2em 0;
}}

.toc li {{
    margin: 0;
    padding: 0.45em 0;
    border-top: 0.5pt solid var(--rule-soft);
    font-size: 10pt;
    line-height: 1.3;
}}

.toc > ul > li {{
    border-top: 0.75pt solid var(--rule);
    padding: 0.7em 0;
    font-size: 11pt;
    font-weight: 600;
}}

.toc ul ul li {{
    font-weight: 400;
    color: var(--ink-soft);
}}

.toc a {{
    text-decoration: none;
    color: var(--ink);
    display: block;
}}

.toc a::after {{
    content: target-counter(attr(href), page);
    float: right;
    color: var(--ink-soft);
    font-weight: 400;
    font-variant-numeric: tabular-nums;
}}

/* === Footnotes — at page bottom === */
.footnote {{
    font-size: 8.5pt;
    color: var(--ink-soft);
}}

.footnote-ref {{
    vertical-align: super;
    font-size: 0.75em;
    text-decoration: none;
    color: var(--accent);
    font-weight: 600;
    margin-left: 1pt;
}}

.footnote-backref {{
    text-decoration: none;
    color: var(--accent);
    padding-left: 0.3em;
    font-size: 0.85em;
}}

div.footnote {{
    margin-top: 3em;
    border-top: 0.5pt solid var(--rule);
    padding-top: 1em;
}}

div.footnote ol {{
    padding-left: 1.5em;
    font-size: 8.5pt;
    color: var(--ink-soft);
}}

div.footnote li {{
    margin: 0.4em 0;
    line-height: 1.45;
}}

div.footnote a {{
    color: var(--accent);
}}

/* === Glossary anchors — heading-based for proper jump targets === */
h3[id] {{
    /* Glossary terms get scroll-margin so PDF anchor jumps are positioned cleanly */
    scroll-margin-top: 1cm;
}}
"""


def markdown_to_pdf(md_file: str, pdf_file: str | None = None, lang: str = "ru") -> str:
    """
    Convert a markdown file to PDF.

    Args:
        md_file: Path to input markdown file.
        pdf_file: Path to output PDF (optional; defaults to same stem as input).
        lang: HTML lang attribute. One of: "ru", "uk", "en". Cosmetic —
              affects hyphenation hints; glyph rendering is driven by the font
              stack in _build_css() regardless.

    Returns:
        Path to generated PDF file.
    """
    if lang not in SUPPORTED_LANGS:
        raise ValueError(f"lang must be one of {SUPPORTED_LANGS}, got {lang!r}")

    md_path = Path(md_file)

    if pdf_file is None:
        pdf_file = str(md_path.with_suffix('.pdf'))

    md_content = md_path.read_text(encoding='utf-8')

    html_content = markdown.markdown(
        md_content,
        extensions=[
            'tables',
            'fenced_code',
            'codehilite',
            'toc',
            'footnotes',
            'attr_list',
            'sane_lists',
        ],
        extension_configs={
            'toc': {
                'title': 'Оглавление' if lang in ('ru', 'uk') else 'Table of Contents',
                'permalink': False,
                'toc_depth': '2-3',
            },
            'footnotes': {
                'BACKLINK_TEXT': '↩',
            },
        }
    )

    full_html = f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
    <meta charset="UTF-8">
    <title>{md_path.stem}</title>
</head>
<body>
{html_content}
</body>
</html>"""

    HTML(string=full_html).write_pdf(pdf_file, stylesheets=[CSS(string=_build_css(_FONTS_DIR))])

    return pdf_file


def main():
    parser = argparse.ArgumentParser(
        description="Convert markdown to A4 PDF (Russian / Ukrainian / English).",
    )
    parser.add_argument("input", help="Input markdown file")
    parser.add_argument(
        "output",
        nargs="?",
        default=None,
        help="Output PDF file (default: input stem with .pdf)",
    )
    parser.add_argument(
        "--lang",
        choices=SUPPORTED_LANGS,
        default="ru",
        help="HTML lang attribute (default: ru)",
    )

    args = parser.parse_args()

    if not Path(args.input).exists():
        print(f"Error: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    output = markdown_to_pdf(args.input, args.output, lang=args.lang)
    print(f"Generated: {output}")


if __name__ == "__main__":
    main()
