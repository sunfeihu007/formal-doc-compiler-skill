# Full script example

Minimal working .docx generator that uses every helper from SKILL.md. Adapt the `children` array — that's where your document content lives.

```javascript
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

// === Content ===
const children = [];

// Cover
children.push(coverTitle("项目名称", 60));
children.push(new Paragraph({ children: [new PageBreak()] }));

// Chapter 1
children.push(h1("第一章  项目概述"));
children.push(h2("1.1  项目名称"));
children.push(p("本项目（以下简称“本项目”）。"));
children.push(h2("1.2  项目背景"));
children.push(p("..."));
children.push(req("一", "..."));
children.push(req("二", "..."));

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

## Run

```bash
cd <build-dir> && npm init -y >/dev/null && npm install docx
node build.js
```

## Sanity check the result

```bash
# Layout check — converts to PDF, rasterizes page 1
python ${CLAUDE_PLUGIN_ROOT}/../anthropic-skills/skills/docx/scripts/office/soffice.py \
  --headless --convert-to pdf output.docx
pdftoppm -jpeg -r 100 -f 1 -l 1 output.pdf preview
# Then Read preview-1.jpg
```

If the rendered page has obvious typographic problems (font defaulted to Times New Roman, indent missing, page number missing) — re-read the SKILL.md constants and re-run.
