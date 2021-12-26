from markdown.extensions import Extension
from markdown.inlinepatterns import SimpleTagInlineProcessor
from markdown.postprocessors import Postprocessor
import re

class MyTagsExtension(Extension):
  def __init__(self, **kwargs):
    self.config = {
      'list_class': ['checklist',
              'class name to add to the list element'],
      'render_item': [render_item, 'custom function to render items'],
    }
    super(MyTagsExtension, self).__init__(**kwargs)

  def extendMarkdown(self, md):
    del_proc = SimpleTagInlineProcessor(r'(\~\~)(.+?)(\~\~)', 'del')
    md.inlinePatterns.register(del_proc, 'del', 200)

    ins_proc = SimpleTagInlineProcessor(r'(\+\+)(.+?)(\+\+)', 'ins')
    md.inlinePatterns.register(ins_proc, 'ins', 200)

    mark_proc = SimpleTagInlineProcessor(r'(\?\?)(.+?)(\?\?)', 'mark')
    md.inlinePatterns.register(mark_proc, 'mark', 200)

    super_proc = SimpleTagInlineProcessor(r'(\^\^)(.+?)(\^\^)', 'sup')
    md.inlinePatterns.register(super_proc, 'sup', 200)

    sub_proc = SimpleTagInlineProcessor(r'(\,\,)(.+?)(\,\,)', 'sub')
    md.inlinePatterns.register(sub_proc, 'sub', 200)

    # Add check-list support
    list_class = self.getConfig('list_class')
    renderer = self.getConfig('render_item')
    postprocessor = ChecklistPostprocessor(list_class, renderer, md)
    md.postprocessors.add('checklist', postprocessor, '>raw_html')

def makeExtension(*args,**kwargs):
  return MyTagsExtension(*args, **kwargs)


#
# Needed fore checklist support
class ChecklistPostprocessor(Postprocessor):
    """
    adds checklist class to list element
    """

    list_pattern = re.compile(r'(<ul>\n<li>\[[ Xx]\])')
    item_pattern = re.compile(r'^<li>\[([ Xx])\](.*)</li>$', re.MULTILINE)

    def __init__(self, list_class, render_item, *args, **kwargs):
        self.list_class = list_class
        self.render_item = render_item
        super(ChecklistPostprocessor, self).__init__(*args, **kwargs)

    def run(self, html):
        html = re.sub(self.list_pattern, self._convert_list, html)
        return re.sub(self.item_pattern, self._convert_item, html)

    def _convert_list(self, match):
        return match.group(1).replace('<ul>',
                '<ul class="%s">' % self.list_class)

    def _convert_item(self, match):
        state, caption = match.groups()
        return self.render_item(caption, state != ' ')


def render_item(caption, checked):
    checked = ' checked' if checked else ''
    return '<li><input type="checkbox" disabled%s>%s</li>' % (checked, caption)

if __name__ == '__main__':
  # ~ import doctest
  # ~ doctest.testfile('README.md')
  pass
