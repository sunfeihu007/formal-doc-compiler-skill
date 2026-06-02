#!/usr/bin/env python3
"""Scan a document for terms in a compliance wordlist.

Usage:
    python3 scan.py --doc path/to/draft.docx --wordlist .compliance/wordlist.yaml
"""
import argparse
import json
import re
import sys
from pathlib import Path

import yaml


def extract_text(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix == ".docx":
        from docx import Document
        d = Document(str(path))
        parts = [p.text for p in d.paragraphs]
        for t in d.tables:
            for row in t.rows:
                for cell in row.cells:
                    parts.append(cell.text)
        return "\n".join(parts)
    if suffix == ".pdf":
        import subprocess
        return subprocess.check_output(
            ["pdftotext", "-layout", str(path), "-"], text=True
        )
    if suffix == ".pptx":
        from pptx import Presentation
        p = Presentation(str(path))
        parts = []
        for slide in p.slides:
            for shape in slide.shapes:
                if shape.has_text_frame:
                    parts.append(shape.text_frame.text)
        return "\n".join(parts)
    if suffix in {".md", ".txt", ".html"}:
        return path.read_text(encoding="utf-8")
    raise ValueError(f"Unsupported extension: {suffix}")


def scan(text: str, wordlist: dict) -> list:
    hits = []
    for cat, spec in wordlist.get("categories", {}).items():
        suggestion = spec.get("suggested_replacement", "")
        for term in spec.get("terms", []):
            is_regex = any(c in term for c in r".\[](){}|+*?^$")
            pattern = term if is_regex else re.escape(term)
            for m in re.finditer(pattern, text):
                start = max(0, m.start() - 30)
                end = min(len(text), m.end() + 30)
                ctx = text[start:end].replace("\n", " ")
                hits.append({
                    "category": cat,
                    "term": term,
                    "matched": m.group(0),
                    "context": ctx,
                    "suggested_replacement": suggestion,
                })
    return hits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--doc", required=True)
    ap.add_argument("--wordlist", required=True)
    args = ap.parse_args()

    doc_path = Path(args.doc)
    wl_path = Path(args.wordlist)

    if not doc_path.exists():
        print(json.dumps({"error": f"document not found: {doc_path}"}))
        sys.exit(1)
    if not wl_path.exists():
        print(json.dumps({"error": f"wordlist not found: {wl_path}"}))
        sys.exit(1)

    text = extract_text(doc_path)
    wordlist = yaml.safe_load(wl_path.read_text(encoding="utf-8")) or {}
    hits = scan(text, wordlist)

    for h in hits:
        print(json.dumps(h, ensure_ascii=False))

    total_terms = sum(
        len(cat.get("terms", []))
        for cat in wordlist.get("categories", {}).values()
    )
    print(json.dumps({
        "summary": True,
        "hits": len(hits),
        "terms_checked": total_terms,
        "doc": str(doc_path),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
