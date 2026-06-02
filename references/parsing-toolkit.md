# Parsing toolkit

Exact shell incantations for each supported source format. Run multiple parses in parallel where files are independent — one bash call per file, fired in the same response.

## .docx

```bash
python3 -c "
from docx import Document
d = Document('PATH.docx')
for p in d.paragraphs:
    t = p.text.strip()
    if t:
        print(f'[{p.style.name}] {t}')
print('--- TABLES ---')
for i, tbl in enumerate(d.tables):
    print(f'### Table {i}')
    for row in tbl.rows:
        cells = [c.text.strip().replace('\n', ' | ') for c in row.cells]
        print(' || '.join(cells))
"
```

The `[Heading 1]`, `[Heading 2]`, `[Normal]` style markers tell you the document's outline at a glance. Tables come out as pipe-separated rows you can read directly.

For very large .docx files (>50 pages), pipe through `head -400` to skim first; expand only if needed.

## .pdf

```bash
pdftotext -layout 'PATH.pdf' - | head -400
```

`-layout` preserves columnar / table structure. Drop `head` if the PDF is short.

For scanned / image-only PDFs:

```bash
# Detect: if pdftotext returns mostly empty pages, OCR is needed.
ocrmypdf 'PATH.pdf' 'PATH.ocr.pdf'
pdftotext -layout 'PATH.ocr.pdf' -
```

## .pptx

```bash
python3 -c "
from pptx import Presentation
p = Presentation('PATH.pptx')
for i, slide in enumerate(p.slides, 1):
    print(f'--- Slide {i} ---')
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                t = para.text.strip()
                if t:
                    print(t)
    if slide.has_notes_slide:
        notes = slide.notes_slide.notes_text_frame.text.strip()
        if notes:
            print(f'[notes] {notes}')
"
```

## .xlsx / .csv

```bash
python3 -c "
import openpyxl
wb = openpyxl.load_workbook('PATH.xlsx', data_only=True, read_only=True)
for ws in wb.worksheets:
    print(f'### Sheet: {ws.title} ({ws.max_row}r x {ws.max_column}c)')
    for r in ws.iter_rows(min_row=1, max_row=min(50, ws.max_row), values_only=True):
        print(' | '.join('' if v is None else str(v)[:60] for v in r))
"
```

Skim 50 rows first. Expand on demand.

For .csv, use `python -c "import pandas as pd; print(pd.read_csv('PATH.csv').head(50))"`.

## .md / .txt / .html

Use the Read tool. No conversion needed.

## Outsourcing to a subagent

When a single parse exceeds 40k characters of output, do not return it to the main context. Instead:

```
Agent(
  description="Slice and distill <filename>",
  subagent_type="general-purpose",
  prompt="
    Slice <full-path> in 40,000-char spans via Python (open(path).read()[A:B]).
    Read every span. The file is a parsed <docx/pdf>.

    Return a structured distillate:
    - High-signal facts: numbers, dates, named constraints, quoted client demands.
    - Mandatory verbatim quotes the final document must reuse.
    - Forbidden / sensitive items the document must avoid.
    - A 5–10 line chapter-by-chapter outline of the source.

    Keep the response under 1500 words.
  "
)
```

The point is to keep the main context clean — only the structured distillate comes back.

## Reading PDFs visually

If a PDF contains diagrams or layout you need to *see* (not extract as text), rasterize and Read the image:

```bash
pdftoppm -jpeg -r 100 -f PAGE -l PAGE 'PATH.pdf' /tmp/preview
# Read /tmp/preview-PAGE.jpg with the Read tool
```

Use `-r 100` for skimming, `-r 150` for typographical detail.
