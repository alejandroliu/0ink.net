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
date: 2013-05-27
---

Quick reference article for how to use Emacs.  Yes, it is really
old skool!

# Cursor Motion

|Key|Cursor Motion|
|--- |--- |
|C-f|Forward one character|
|C-b|Backward one character|
|C-n|Next line|
|C-p|Previous line|
|C-a|Beginning of line|
|C-e|End of line|
|C-v|Next screenful|
|M-v|Previous screenful|
|M-<|Beginning of buffer|
|M->|End of buffer|
|C-s|Search forward incrementally|
|C-r|Reverse search incrementally|
|C-u C-s|Reg-Exp Search forward incrementally|
|C-u C-r|Reg-Exp Reverse search incrementally|
|C-x C-x|Swap mark and cursor|
|C-Space|Set mark|
|C-l|Cursor to the middle of the screen|
|M-}|Forward one paragraph|
|M-{|Backward one paragraph|


# Text editing

|Key|Editing|
|--- |--- |
|C-q|Literal command|
|C-d|Delete next character|
|Backspc|Delete previous character|
|M-%|Query string replacement|
|M-d|Delete next word|
|M-Bcksp|Delete previous word|
|C-k|Kill to end of line (delete to end of line)|
|C-w|Cut region|
|M-w|Copy region|
|C-y|Yank most recent cut/copy (paste command)|
|M-y|Replace yanked text with previously cut/copy text (only works immediatly after C-y or another M-y)|
|C-x u|undo|
|C-u ##|Repeat the next command|


# File Commands

|Key|Files|
|--- |--- |
|C-x C-f|Open a file|
|C-x C-s|Save buffer to file|
|C-x C-w|Write buffer to file (Save As)|
|C-x C-c|Exit Emacs|
|C-x s|Save all buffers|
|C-x i|Insert file|
|C-g|Cancel current command|
|C-z|Suspend/Minimize Emacs|


# Buffers

|Key|Buffers|
|--- |--- |
|C-x b|Switch to buffer|
|C-x 1|Close all other buffers|
|C-x 2|Split current buffer in tow|
|C-x 3|Split current buffer horizontally|
|C-x 0|Close current buffer|
|C-x o|Switch to other buffer|
|C-x C-b|List buffers|
|C-x k|Kill buffer|
|C-x ^|Grow window vertically; prefix is number of lines|

# Help

|Key|Help|
|--- |--- |
|C-h C-h|Help menu|
|C-h i|Info|
|C-h a|Apropos|
|C-h b|Key bindings|
|C-h m|Mode help|
|C-h k|Show command documentation; prompts for keystrokes|
|C-h c|Show command name on message line; prompts for keystrokes|
|C-h f|Describe function; prompts for command or function name, shows documentation in other window|
|C-h i|Info browser; gives access to online documentation for emacs and more|


# Misc

|Key|Other|
|--- |--- |
|M-/|Abbreviation|
|M-q|Autoformat current text region|
|C-M-|Re-indent current region|
|C-x (|Start defining macro|
|C-x )|Stop macro defintion|
|C-x e|Execute macro|

# C-Mode Commands

|Key|C-Mode|
|--- |--- |
|C-j|Insert a newline and indent the next line.|
|C-c C-q|Fix indentation of current function|
|C-c C-a|Toggle the auto-newline-insertion mode. (If it was off, it will now be on and vice versa.)|
|C-c C-d|Toggle the hungry delete mode|

# Extended commands

Enter `ESC` + `[` and enter this text:

|M-x|Commands|
|--- |--- |
|c-set-style|Change the indentation style|
|replace-string|Global string replacement|
|revert-buffer|Throw out all changes and revert to the last saved version of the file.|
|gdb|Start GNU debugger|
|shell|Start shell in new buffer|
|print-buffer|Send the contents of the current buffer to the printer|
|compile|Compile a program|
|set-variable|Change the value of an Emacs variable to customize Emacs|
|artist-mode|Start artist mode|
|artist-mode-off|Exit artist mode|
|tabify|...|
|untabify|...|


# Tags

Use tags to navigate source code. It's not hard to set up. This takes advantage of a popular tool called "Exuberant Ctags" (AKA ctags, or etags) that scans your source code and indexes the symbols into a `TAGS` file. Note: emacs comes with a tool called "etags" that does almost the same thing as Exuberant Ctags. In cygwin, the "etags" binary is actually Exuberant Ctags. Confused yet? My advice is, ignore Emacs etags, and use Exuberant Ctags, whatever it happens to be called in your part of the universe. To generate a `TAGS` file, do this in the root of your code tree (stick this in a script or Makefile):

```
#ETAGS=/cygdrive/c/emacs-21.3/bin/etags.exe
ETAGS=etags # Exuberant ctags
rm TAGS
find . -name '*.cpp' -o -name '*.h' -o -name '*.c' -print0 
     | xargs $(ETAGS) --extra=+q --fields=+fksaiS --c++-kinds=+px --append

```

Then, when you're reading code and want to see the definition(s) of a symbol:

*   `M-.`: goes to the symbol definition
*   `M-0 M-.`: goes to the next matching definition
*   `M-*`: return to your starting point

