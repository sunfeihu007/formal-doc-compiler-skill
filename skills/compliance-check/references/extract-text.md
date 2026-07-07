# Text extraction recipes

These are the canonical commands. The bundled `scan.py` already calls these internally; the recipes here are for ad-hoc use when you want to sanity-check what's being scanned.

## .docx

```python
from docx import Document
d = Document("draft.docx")
text = "\n".join(p.text for p in d.paragraphs)
# also walk tables — cell text is not in paragraphs
for t in d.tables:
    for row in t.rows:
        for cell in row.cells:
            text += "\n" + cell.text
```

## .pdf

```bash
pdftotext -layout draft.pdf -
```

`-layout` preserves columnar structure. Scanned PDFs need OCR first (`ocrmypdf in.pdf out.pdf`).

## .pptx

```python
from pptx import Presentation
p = Presentation("draft.pptx")
text = []
for slide in p.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            text.append(shape.text_frame.text)
text = "\n".join(text)
```

Also walks notes if you want them:

```python
if slide.has_notes_slide:
    text.append(slide.notes_slide.notes_text_frame.text)
```

## .xlsx

```python
import openpyxl
wb = openpyxl.load_workbook("draft.xlsx", data_only=True, read_only=True)
text = []
for ws in wb.worksheets:
    for row in ws.iter_rows(values_only=True):
        for v in row:
            if v is not None:
                text.append(str(v))
text = "\n".join(text)
```

## .md / .txt / .html

Just `path.read_text(encoding="utf-8")`.

## Gotchas

- **Headers / footers in .docx** — `python-docx` does *not* walk `section.header.paragraphs` by default. If your draft puts compliance-relevant content in headers/footers, walk those sections explicitly.
- **Embedded images with text** — scanner won't catch OCR'd text inside embedded images. For high-stakes drafts, OCR images first.
- **Hidden / tracked-changes content** — `python-docx` returns the accepted form. Reject changes first if you need to scan the original.
