---
name: cn-formal-style
description: "Apply Chinese formal-document typography to a generated .docx. Use whenever the deliverable is a Chinese-language official document — government reports, tender/RFP technical requirements, board memos, project plans, research briefs, white papers, regulatory submissions — and the output must look professionally typeset (黑体 headings, 宋体 body, 2-character first-line indent, 1.5 line spacing, A4 page, 1-inch margins, header/footer, 一/二/三 clause numbering). Provides ready-to-paste docx-js helper functions and parameter constants. Pairs with the format skill for docx (anthropic-skills:docx) — read both."
---

# Chinese formal-document typography

## When this fires

The deliverable is a Chinese formal long-form document (government report, tender / RFP, board memo, project plan, research brief, white paper, regulatory submission) and you want it to read as professional, idiomatic output rather than "an AI wrote this in default Word style."

This is a typography reference, not a content reference. It does not influence what you write — only how it renders.

## Why these specific choices

The conventions here match what is actually used in Chinese government, banking, and large-enterprise documents:

- **黑体** (sans-serif, bold-feeling) for headings — by tradition, headings are 黑体
- **宋体** (serif) for body — readable at 12pt, standard for official text
- **2-character first-line indent** — every body paragraph indents 2 Chinese characters, equivalent to 480 DXA. Unindented paragraphs read as "list items" or "callouts," not body.
- **1.5 line spacing** (`line: 360`) — gives the document breathing room without being airy
- **A4 portrait, 1-inch margins** — the de facto standard for printed Chinese documents
- **(一)(二)(三) clause numbering** — the conventional way to enumerate requirements / clauses in a formal document. NOT 1. 2. 3., which reads as informal.

## Parameter constants

Copy verbatim into your docx-js generation script:

```javascript
// Fonts
const FONT_HEI  = "黑体";       // headings
const FONT_SONG = "宋体";       // body
const FONT_FANG = "仿宋";       // optional, for cover / quotes

// Sizes (docx-js uses half-points: 24 = 12pt)
const SIZE_H1     = 36;   // 18pt — chapter title
const SIZE_H2     = 30;   // 15pt — section
const SIZE_H3     = 26;   // 13pt — subsection
const SIZE_H4     = 24;   // 12pt — sub-subsection
const SIZE_BODY   = 24;   // 12pt — body text
const SIZE_TABLE  = 22;   // 11pt — table cells
const SIZE_FOOTER = 18;   //  9pt — header / footer

// Page (A4, 1-inch margins)
const PAGE_WIDTH  = 11906;  // A4 width in DXA
const PAGE_HEIGHT = 16838;
const MARGIN      = 1440;   // 1 inch

// Paragraph
const FIRST_LINE_INDENT = 480;  // 2 Chinese characters
const LINE_SPACING_BODY = 360;  // 1.5x
const LINE_SPACING_H1   = 400;
```

## Helper functions

```javascript
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, BorderStyle, WidthType,
  ShadingType, HeadingLevel, PageNumber, PageBreak
} = require('docx');

// Body paragraph with 2-char first-line indent
function p(text) {
  return new Paragraph({
    spacing: { before: 60, after: 60, line: LINE_SPACING_BODY },
    indent: { firstLine: FIRST_LINE_INDENT },
    alignment: AlignmentType.JUSTIFIED,
    children: [new TextRun({ text, font: FONT_SONG, size: SIZE_BODY })],
  });
}

// Body paragraph without indent (use sparingly)
function pNoIndent(text) {
  return new Paragraph({
    spacing: { before: 60, after: 60, line: LINE_SPACING_BODY },
    alignment: AlignmentType.JUSTIFIED,
    children: [new TextRun({ text, font: FONT_SONG, size: SIZE_BODY })],
  });
}

// Heading 1 — chapter title, centered
function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 240, line: LINE_SPACING_H1 },
    alignment: AlignmentType.CENTER,
    children: [new TextRun({ text, font: FONT_HEI, size: SIZE_H1, bold: true })],
  });
}

// Heading 2 — section
function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 280, after: 160, line: 380 },
    children: [new TextRun({ text, font: FONT_HEI, size: SIZE_H2, bold: true })],
  });
}

// Heading 3 — subsection
function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 120, line: 360 },
    children: [new TextRun({ text, font: FONT_HEI, size: SIZE_H3, bold: true })],
  });
}

// Numbered requirement clause: （一）...  （二）...
function req(num, text) {
  return new Paragraph({
    spacing: { before: 60, after: 60, line: LINE_SPACING_BODY },
    indent: { left: 480, hanging: 480 },
    alignment: AlignmentType.JUSTIFIED,
    children: [
      new TextRun({ text: `（${num}）`, font: FONT_SONG, size: SIZE_BODY }),
      new TextRun({ text, font: FONT_SONG, size: SIZE_BODY }),
    ],
  });
}

// Cover-page big title
function coverTitle(text, size = 56) {
  return new Paragraph({
    spacing: { before: 240, after: 240 },
    alignment: AlignmentType.CENTER,
    children: [new TextRun({ text, font: FONT_HEI, size, bold: true })],
  });
}
```

## Tables

```javascript
const tBorder  = { style: BorderStyle.SINGLE, size: 4, color: "808080" };
const tBorders = {
  top: tBorder, bottom: tBorder, left: tBorder, right: tBorder,
  insideHorizontal: tBorder, insideVertical: tBorder
};

function tableCell(text, opts = {}) {
  const { width = 4680, header = false } = opts;
  return new TableCell({
    width: { size: width, type: WidthType.DXA },
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    shading: header ? { fill: "D9E2F3", type: ShadingType.CLEAR } : undefined,
    children: [new Paragraph({
      alignment: AlignmentType.LEFT,
      children: [new TextRun({
        text, font: FONT_SONG, size: SIZE_TABLE, bold: header
      })],
    })],
  });
}

function table(headers, rows, widths) {
  const totalWidth = widths.reduce((a, b) => a + b, 0);
  return new Table({
    width: { size: totalWidth, type: WidthType.DXA },
    columnWidths: widths,
    borders: tBorders,
    rows: [
      new TableRow({
        tableHeader: true,
        children: headers.map((h, i) => tableCell(h, { width: widths[i], header: true })),
      }),
      ...rows.map(row => new TableRow({
        children: row.map((c, i) => tableCell(c, { width: widths[i] })),
      })),
    ],
  });
}
```

## Pre-flight checks before running the script

- **Content lives in JSON, not in the script.** Per Step 7 of the compile workflow, put all document text in a JSON data file the script reads at runtime. JSON round-trips full-width Chinese quotes "" without any escaping issues — the whole class of quote-collapse bugs disappears. Only if you inherited a legacy script with embedded content do you need the repair recipe in `references/quote-fix-script.md`.
- **Smart numbers.** Never hard-code arabic 1. 2. 3. for requirement clauses. Use the `req("一", ...)` helper.
- **Empty paragraphs.** Don't insert empty `Paragraph({ children: [new TextRun("")] })` for spacing. Adjust `spacing` on the next paragraph instead.

## Detailed references

- `references/full-script-example.md` — complete generation script template
- `references/quote-fix-script.md` — repair recipe for legacy scripts with content embedded in JS string literals
