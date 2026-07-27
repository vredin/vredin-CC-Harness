#!/usr/bin/env python3
"""
Batch-convert multiple markdown files to PDF.

Usage:
    python batch_convert.py file1.md file2.md file3.md
    python batch_convert.py *.md
    python batch_convert.py --output-dir ./pdfs file1.md file2.md
    python batch_convert.py --lang uk *.md

Requirements:
    pip install weasyprint markdown
    (or: uv run --with weasyprint --with markdown batch_convert.py ...)
"""

import argparse
import sys
from pathlib import Path

from md_to_pdf import SUPPORTED_LANGS, markdown_to_pdf


def main():
    parser = argparse.ArgumentParser(
        description="Batch-convert markdown files to PDF (Russian / Ukrainian / English).",
    )
    parser.add_argument("files", nargs="+", help="Markdown files to convert")
    parser.add_argument(
        "--output-dir", "-o",
        type=str,
        default=None,
        help="Output directory for PDFs (default: same directory as each input)",
    )
    parser.add_argument(
        "--lang",
        choices=SUPPORTED_LANGS,
        default="ru",
        help="HTML lang attribute applied to all files (default: ru)",
    )

    args = parser.parse_args()

    output_dir = Path(args.output_dir) if args.output_dir else None
    if output_dir:
        output_dir.mkdir(parents=True, exist_ok=True)

    success = 0
    failed = 0

    for md_file in args.files:
        md_path = Path(md_file)

        if not md_path.exists():
            print(f"[SKIP] File not found: {md_file}")
            failed += 1
            continue

        if md_path.suffix.lower() != ".md":
            print(f"[SKIP] Not a markdown file: {md_file}")
            failed += 1
            continue

        if output_dir:
            pdf_file = str(output_dir / md_path.with_suffix(".pdf").name)
        else:
            pdf_file = str(md_path.with_suffix(".pdf"))

        try:
            print(f"Converting: {md_file} -> {pdf_file}")
            markdown_to_pdf(str(md_path), pdf_file, lang=args.lang)
            success += 1
        except Exception as exc:  # noqa: BLE001 — top-level loop reporter
            print(f"[ERROR] Failed to convert {md_file}: {exc}")
            failed += 1

    print(f"\nCompleted: {success} succeeded, {failed} failed")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
