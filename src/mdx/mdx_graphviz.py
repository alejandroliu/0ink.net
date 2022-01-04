#
# Stupid graphviz processor
#
# ~ from __future__ import unicode_literals, absolute_import

from markdown.extensions import Extension
from markdown.blockprocessors import BlockProcessor
from markdown.util import etree
import re
import subprocess
import base64
from urllib.parse import quote as url_quote

# ~ from pprint import pprint

# ~ from markdown_blockdiag.utils import draw_blockdiag, DIAG_MODULES

COMMANDS = {
    'dot', 'neato', 'fdp', 'sfdp', 'twopi', 'circo'
}

class GraphVizProcessor(BlockProcessor):
  RE = re.compile(r"""
        ^
        (?P<diagtype>{})
        \s*
        \{{
    """.format("|".join(COMMANDS)), re.VERBOSE)

  def __init__(self, parser, extension):
    super(GraphVizProcessor, self).__init__(parser)
    self.extension = extension

  def test(self, parent, block):
    return bool(self.RE.match(block))

  def run(self, parent, blocks):
    gv_blocks = []

    for block in blocks:
      block = block.strip()

      gv_blocks.append(block)
      if block.endswith("}"):
        break

    raw_block = "\n".join(gv_blocks)
    del blocks[:len(gv_blocks)]


    output_fmt = self.extension.getConfig('format')

    # ~ print([raw_block,output_fmt])
    cmdtype, content = raw_block.split(' ',1)
    cmdtype = cmdtype.strip()
    content = content.strip()

    # ~ pprint(content)

    if content.startswith('{') and content.endswith('}'):
      content = content[1:-1].strip()
    # ~ pprint(content)


    # Spawn graphviz
    proc = subprocess.Popen([cmdtype,'-T'+output_fmt],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    proc.stdin.write(content.encode('utf-8'))
    out,err = proc.communicate()

    if out == b'':
      if err == b'': err = b'No Outputr'
      raise Exception('GraphViz-'+err.decode('utf-8'))

    # ~ pprint([out,err])

    # ~ print([cmdtype,content])
    if output_fmt == 'png':
      src_data = 'data:image/png;base64,{0}'.format(
              base64.b64encode(out).decode('ascii')
          )
    else:
      src_data = 'data:image/svg+xml;charset=utf-8,{0}'.format(url_quote(out))

    p = etree.SubElement(parent, 'p')
    img = etree.SubElement(p, 'img')
    img.attrib['src'] = src_data



class GraphVizExtension(Extension):

    def __init__(self, **kwargs):
        self.config = {
            'format': ['svg', 'Format to use (png/svg)'],
        }
        super(GraphVizExtension, self).__init__(**kwargs)

    def extendMarkdown(self, md, md_globals):
        md.parser.blockprocessors.register(
            GraphVizProcessor(md.parser,self), 'grapviz',175)
        md.registerExtension(self)


def makeExtension(**kwargs):
  return GraphVizExtension(**kwargs)
