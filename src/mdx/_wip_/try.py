#
# Test
#
import markdown
# ~ import mdx_graphviz

lines = []
with open('dot.md','r') as fp:
  for ln in fp:
    if ln[-1:] == '\n': ln = ln[:-1]
    lines.append(ln)

html = markdown.markdown('\n'.join(lines),
                          extensions=['mdx_graphviz'])

print('====')
print(html)

with open('out.html','w') as fp:
  fp.write(html)
