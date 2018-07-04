---
ID: "360"
post_author: "2"
post_date: "2013-05-27 11:16:26"
post_date_gmt: "2013-05-27 11:16:26"
post_title: Emacs Cheat Sheet
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: emacs-cheat-sheet
to_ping: ""
pinged: ""
post_modified: "2013-05-27 11:16:26"
post_modified_gmt: "2013-05-27 11:16:26"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=360
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Emacs Cheat Sheet

---

<h1>Cursor Motion</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Cursor Motion</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-f</td>
  <td>Forward one character</td>
</tr>
<tr>
  <td>C-b</td>
  <td>Backward one character</td>
</tr>
<tr>
  <td>C-n</td>
  <td>Next line</td>
</tr>
<tr>
  <td>C-p</td>
  <td>Previous line</td>
</tr>
<tr>
  <td>C-a</td>
  <td>Beginning of line</td>
</tr>
<tr>
  <td>C-e</td>
  <td>End of line</td>
</tr>
<tr>
  <td>C-v</td>
  <td>Next screenful</td>
</tr>
<tr>
  <td>M-v</td>
  <td>Previous screenful</td>
</tr>
<tr>
  <td>M-&lt;</td>
  <td>Beginning of buffer</td>
</tr>
<tr>
  <td>M-&gt;</td>
  <td>End of buffer</td>
</tr>
<tr>
  <td>C-s</td>
  <td>Search forward incrementally</td>
</tr>
<tr>
  <td>C-r</td>
  <td>Reverse search incrementally</td>
</tr>
<tr>
  <td>C-u C-s</td>
  <td>Reg-Exp Search forward incrementally</td>
</tr>
<tr>
  <td>C-u C-r</td>
  <td>Reg-Exp Reverse search incrementally</td>
</tr>
<tr>
  <td>C-x C-x</td>
  <td>Swap mark and cursor</td>
</tr>
<tr>
  <td>C-Space</td>
  <td>Set mark</td>
</tr>
<tr>
  <td>C-l</td>
  <td>Cursor to the middle of the screen</td>
</tr>
<tr>
  <td>M-}</td>
  <td>Forward one paragraph</td>
</tr>
<tr>
  <td>M-{</td>
  <td>Backward one paragraph</td>
</tr>
</tbody>
</table>

<h1>Text editing</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Editing</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-q</td>
  <td>Literal command</td>
</tr>
<tr>
  <td>C-d</td>
  <td>Delete next character</td>
</tr>
<tr>
  <td>Backspc</td>
  <td>Delete previous character</td>
</tr>
<tr>
  <td>M-%</td>
  <td>Query string replacement</td>
</tr>
<tr>
  <td>M-d</td>
  <td>Delete next word</td>
</tr>
<tr>
  <td>M-Bcksp</td>
  <td>Delete previous word</td>
</tr>
<tr>
  <td>C-k</td>
  <td>Kill to end of line (delete to end of line)</td>
</tr>
<tr>
  <td>C-w</td>
  <td>Cut region</td>
</tr>
<tr>
  <td>M-w</td>
  <td>Copy region</td>
</tr>
<tr>
  <td>C-y</td>
  <td>Yank most recent cut/copy (paste command)</td>
</tr>
<tr>
  <td>M-y</td>
  <td>Replace yanked text with previously cut/copy text (only works immediatly after C-y or another M-y)</td>
</tr>
<tr>
  <td>C-x u</td>
  <td>undo</td>
</tr>
<tr>
  <td>C-u ##</td>
  <td>Repeat the next command</td>
</tr>
</tbody>
</table>

<h1>File Commands</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Files</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-x C-f</td>
  <td>Open a file</td>
</tr>
<tr>
  <td>C-x C-s</td>
  <td>Save buffer to file</td>
</tr>
<tr>
  <td>C-x C-w</td>
  <td>Write buffer to file (Save As)</td>
</tr>
<tr>
  <td>C-x C-c</td>
  <td>Exit Emacs</td>
</tr>
<tr>
  <td>C-x s</td>
  <td>Save all buffers</td>
</tr>
<tr>
  <td>C-x i</td>
  <td>Insert file</td>
</tr>
<tr>
  <td>C-g</td>
  <td>Cancel current command</td>
</tr>
<tr>
  <td>C-z</td>
  <td>Suspend/Minimize Emacs</td>
</tr>
</tbody>
</table>

<h1>Buffers</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Buffers</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-x b</td>
  <td>Switch to buffer</td>
</tr>
<tr>
  <td>C-x 1</td>
  <td>Close all other buffers</td>
</tr>
<tr>
  <td>C-x 2</td>
  <td>Split current buffer in tow</td>
</tr>
<tr>
  <td>C-x 3</td>
  <td>Split current buffer horizontally</td>
</tr>
<tr>
  <td>C-x 0</td>
  <td>Close current buffer</td>
</tr>
<tr>
  <td>C-x o</td>
  <td>Switch to other buffer</td>
</tr>
<tr>
  <td>C-x C-b</td>
  <td>List buffers</td>
</tr>
<tr>
  <td>C-x k</td>
  <td>Kill buffer</td>
</tr>
<tr>
  <td>C-x ^</td>
  <td>Grow window vertically; prefix is number of lines</td>
</tr>
</tbody>
</table>

<h1>Help</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Help</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-h C-h</td>
  <td>Help menu</td>
</tr>
<tr>
  <td>C-h i</td>
  <td>Info</td>
</tr>
<tr>
  <td>C-h a</td>
  <td>Apropos</td>
</tr>
<tr>
  <td>C-h b</td>
  <td>Key bindings</td>
</tr>
<tr>
  <td>C-h m</td>
  <td>Mode help</td>
</tr>
<tr>
  <td>C-h k</td>
  <td>Show command documentation; prompts for keystrokes</td>
</tr>
<tr>
  <td>C-h c</td>
  <td>Show command name on message line; prompts for keystrokes</td>
</tr>
<tr>
  <td>C-h f</td>
  <td>Describe function; prompts for command or function name, shows documentation in other window</td>
</tr>
<tr>
  <td>C-h i</td>
  <td>Info browser; gives access to online documentation for emacs and more</td>
</tr>
</tbody>
</table>

<h1>Misc</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>Other</th>
</tr>
</thead>
<tbody>
<tr>
  <td>M-/</td>
  <td>Abbreviation</td>
</tr>
<tr>
  <td>M-q</td>
  <td>Autoformat current text region</td>
</tr>
<tr>
  <td>C-M-</td>
  <td>Re-indent current region</td>
</tr>
<tr>
  <td>C-x (</td>
  <td>Start defining macro</td>
</tr>
<tr>
  <td>C-x )</td>
  <td>Stop macro defintion</td>
</tr>
<tr>
  <td>C-x e</td>
  <td>Execute macro</td>
</tr>
</tbody>
</table>

<h1>C-Mode Commands</h1>

<table>
<thead>
<tr>
  <th>Key</th>
  <th>C-Mode</th>
</tr>
</thead>
<tbody>
<tr>
  <td>C-j</td>
  <td>Insert a newline and indent the next line.</td>
</tr>
<tr>
  <td>C-c C-q</td>
  <td>Fix indentation of current function</td>
</tr>
<tr>
  <td>C-c C-a</td>
  <td>Toggle the auto-newline-insertion mode. (If it was off, it will now be on and vice versa.)</td>
</tr>
<tr>
  <td>C-c C-d</td>
  <td>Toggle the hungry delete mode</td>
</tr>
</tbody>
</table>

<h1>Extended commands</h1>

Enter <code>ESC</code> + <code>[</code> and enter this text:

<table>
<thead>
<tr>
  <th>M-x</th>
  <th>Commands</th>
</tr>
</thead>
<tbody>
<tr>
  <td>c-set-style</td>
  <td>Change the indentation style</td>
</tr>
<tr>
  <td>replace-string</td>
  <td>Global string replacement</td>
</tr>
<tr>
  <td>revert-buffer</td>
  <td>Throw out all changes and revert to the last saved version of the file.</td>
</tr>
<tr>
  <td>gdb</td>
  <td>Start GNU debugger</td>
</tr>
<tr>
  <td>shell</td>
  <td>Start shell in new buffer</td>
</tr>
<tr>
  <td>print-buffer</td>
  <td>Send the contents of the current buffer to the printer</td>
</tr>
<tr>
  <td>compile</td>
  <td>Compile a program</td>
</tr>
<tr>
  <td>set-variable</td>
  <td>Change the value of an Emacs variable to customize Emacs</td>
</tr>
<tr>
  <td>artist-mode</td>
  <td>Start artist mode</td>
</tr>
<tr>
  <td>artist-mode-off</td>
  <td>Exit artist mode</td>
</tr>
<tr>
  <td>tabify</td>
  <td>...</td>
</tr>
<tr>
  <td>untabify</td>
  <td>...</td>
</tr>
</tbody>
</table>

<h1>Tags</h1>

Use tags to navigate source code. It's not hard to set up. This takes advantage of a popular tool called "Exuberant Ctags" (AKA ctags, or etags) that scans your source code and indexes the symbols into a <code>TAGS</code>
file.

Note: emacs comes with a tool called "etags" that does almost the same thing as Exuberant Ctags. In cygwin, the "etags" binary is actually Exuberant Ctags. Confused yet? My advice is, ignore Emacs etags, and use Exuberant Ctags, whatever it happens to be called in your part of the universe.

To generate a <code>TAGS</code> file, do this in the root of your code tree (stick this in a script or Makefile):

<pre><code>#ETAGS=/cygdrive/c/emacs-21.3/bin/etags.exe
ETAGS=etags # Exuberant ctags
rm TAGS
find . -name '*.cpp' -o -name '*.h' -o -name '*.c' -print0 
     | xargs $(ETAGS) --extra=+q --fields=+fksaiS --c++-kinds=+px --append
</code></pre>

Then, when you're reading code and want to see the definition(s) of a symbol:

<ul>
<li><code>M-.</code>:  goes to the symbol definition</li>
<li><code>M-0 M-.</code>: goes to the next matching definition</li>
<li><code>M-*</code>: return to your starting point</li>
</ul>

