# Full script example

Minimal working .docx generator using every helper from SKILL.md, in the content/code-separated shape from Step 7 of the compile workflow: the render script below never changes per document — only the JSON data files do.

## The content files

One JSON file per chapter (or one file total for medium documents), an array of typed blocks. JSON round-trips full-width Chinese quotes "" with no escaping issues.

```json
// content/ch1.json
[
  { "type": "h1",  "text": "第一章  项目概述" },
  { "type": "h2",  "text": "1.1  项目名称" },
  { "type": "p",   "text": "本项目（以下简称“本项目”）。" },
  { "type": "h2",  "text": "1.2  项目背景" },
  { "type": "p",   "text": "..." },
  { "type": "req", "num": "一", "text": "..." },
  { "type": "req", "num": "二", "text": "..." },
  { "type": "table",
    "headers": ["指标", "说明"],
    "rows": [["范围", "..."], ["depth", "..."]],
    "widths": [3000, 6360] }
]
```

## The render script

```javascript
// build.js — content-free; reads content/*.json in order
const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, BorderStyle, WidthType,
  ShadingType, HeadingLevel, PageNumber, PageBreak
} = require('docx');

// === Constants (from SKILL.md) ===
const FONT_HEI = "黑体";
const FONT_SONG = "宋体";
const SIZE_BODY = 24;
const FIRST_LINE_INDENT = 480;
const LINE_SPACING_BODY = 360;
const PAGE_WIDTH = 11906;
const PAGE_HEIGHT = 16838;
const MARGIN = 1440;

// === Helpers (from SKILL.md) ===
function p(text) { /* see SKILL.md */ }
function h1(text) { /* see SKILL.md */ }
function h2(text) { /* see SKILL.md */ }
function h3(text) { /* see SKILL.md */ }
function req(num, text) { /* see SKILL.md */ }
function coverTitle(text, size = 56) { /* see SKILL.md */ }
function table(headers, rows, widths) { /* see SKILL.md */ }

// === Block dispatch ===
const RENDER = {
  h1:    b => h1(b.text),
  h2:    b => h2(b.text),
  h3:    b => h3(b.text),
  p:     b => p(b.text),
  req:   b => req(b.num, b.text),
  cover: b => coverTitle(b.text, b.size),
  pagebreak: () => new Paragraph({ children: [new PageBreak()] }),
  table: b => table(b.headers, b.rows, b.widths),
};

const children = [];
for (const file of fs.readdirSync('content').sort()) {
  if (!file.endsWith('.json')) continue;
  for (const block of JSON.parse(fs.readFileSync(`content/${file}`, 'utf-8'))) {
    const render = RENDER[block.type];
    if (!render) throw new Error(`${file}: unknown block type '${block.type}'`);
    children.push(render(block));
  }
}

// === Document ===
const doc = new Document({
  creator: "<author>",
  title: "<title>",
  styles: { /* see SKILL.md */ },
  sections: [{
    properties: {
      page: {
        size: { width: PAGE_WIDTH, height: PAGE_HEIGHT },
        margin: { top: MARGIN, right: MARGIN, bottom: MARGIN, left: MARGIN }
      }
    },
    headers: { /* see SKILL.md */ },
    footers: { /* see SKILL.md */ },
    children: children,
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync('output.docx', buffer);
  console.log('OK', buffer.length, 'bytes');
});
```

Fixing chapter 3's wording means editing `content/ch3.json` and re-running — the script and the other chapters don't change.

## Run

```bash
cd <build-dir> && npm init -y >/dev/null && npm install docx
node build.js
```

## Sanity check the result

```bash
# Layout check — converts to PDF, rasterizes the riskiest pages
soffice --headless --convert-to pdf output.docx   # or LibreOffice via your format skill's converter
pdftoppm -jpeg -r 100 -f 1 -l 1 output.pdf preview
# Then view preview-1.jpg — also rasterize the TOC page and a dense-table page
```

If the rendered page has obvious typographic problems (font defaulted to Times New Roman, indent missing, page number missing) — re-read the SKILL.md constants and re-run.
