# Quote-fix recipe

A reliable issue: when you write a JS generation script via the file tools, full-width Chinese quotes "" sometimes get collapsed to ASCII " — which breaks the JS string literal and the script won't compile.

This recipe restores the full-width quotes around CJK content while preserving ASCII quotes around JS strings.

## The recipe

```python
import re

with open('build.js', 'r', encoding='utf-8') as f:
    src = f.read()

# Smart pass: for each " character, look at the surrounding character.
# ASCII boundary characters mean "JS string boundary" — keep as ASCII.
# CJK characters or alphanumerics mean "embedded literal quote" — convert.
result = []
ascii_boundary = set('([{,;=>:?+-*/!&|^~ \t\n\r')

for i, ch in enumerate(src):
    if ch != '"':
        result.append(ch)
        continue
    prev = src[i-1] if i > 0 else ''
    nxt  = src[i+1] if i+1 < len(src) else ''
    # JS string boundary if either side is an ASCII boundary character
    if prev in ascii_boundary or nxt in ascii_boundary or nxt == ')' or nxt == ']' or nxt == '}':
        result.append(ch)
        continue
    # Otherwise it's embedded inside text — pick left or right quote by context
    if nxt and ('一' <= nxt <= '鿿' or nxt.isalnum()):
        result.append('“')  # left
    else:
        result.append('”')  # right

with open('build.js', 'w', encoding='utf-8') as f:
    f.write(''.join(result))
```

## Verification

```bash
node build.js
```

If still broken, the diff will show the exact line. The common residual bug is a string boundary that this heuristic missed — e.g., `"]` inside an array. Fix-up pass:

```python
# Recover ASCII quotes where they got over-converted next to closing brackets
import re
with open('build.js','r',encoding='utf-8') as f:
    s = f.read()
s = (s.replace('”]', '"]')
       .replace('”}', '"}')
       .replace('”)', '")')
       .replace('”,', '",')
       .replace('”;', '";')
       .replace('”\n', '"\n')
       .replace('[“', '["')
       .replace('{“', '{"')
       .replace('(“', '("'))
with open('build.js','w',encoding='utf-8') as f:
    f.write(s)
```

After both passes the script should parse cleanly.
