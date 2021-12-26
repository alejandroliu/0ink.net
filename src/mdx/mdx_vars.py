from markdown.extensions import Extension
from markdown.preprocessors import Preprocessor
import re

VARSUBST_RE = re.compile(r'\$\{(\w+)\}')
mdx_vars = {}

class VarsPreProc(Preprocessor):
    """ Skip any line with words 'NO RENDER' in it. """
    def run(self, lines):
        new_lines = []
        for line in lines:
          off=0
          new_line = ''
          mv = VARSUBST_RE.search(line,off)
          while not mv is None:
            new_line += line[off:mv.start(0)]
            if mv.group(1) in mdx_vars:
              new_line += mdx_vars[mv.group(1)]
            else:
              new_line += mv.group(0)
            off = mv.end(0)
            mv = VARSUBST_RE.search(line,off)
          new_line += line[off:]
          new_lines.append(new_line)
        return new_lines

class VarsExtension(Extension):
  """ Meta-Data extension for Python-Markdown. """
  def __init__(self, **kwargs):
    self.config = {
      'vars': [{}, 'dict with variable substitutions'],
    }
    super(VarsExtension, self).__init__(**kwargs)

  def extendMarkdown(self, md):
    """ Add MetaPreprocessor to Markdown instance. """
    md.registerExtension(self)
    self.md = md
    md.preprocessors.register(VarsPreProc(md), 'mdxvars', 27)

    vs = self.getConfig('vars')
    for k in vs:
      mdx_vars[k] = vs[k]


def makeExtension(**kwargs):  # pragma: no cover
  return VarsExtension(**kwargs)

