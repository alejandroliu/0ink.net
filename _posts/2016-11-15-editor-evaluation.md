---
title: editor to replace emacs
---

At the end, I switched to [geany](http://www.geany.org/)

# GUI

- [TextAdept](https://foicica.com/textadept/)
- [Bluefish Editor](http://bluefish.openoffice.nl/index.html)
- [editra](http://editra.org/)
- [gedit](https://wiki.gnome.org/Apps/Gedit)

# Console

- [sanos editor](http://www.jbox.dk/sanos/editor.htm)
- [eFTE](https://github.com/lanurmi/efte)
- [Tilde](http://os.ghalkes.nl/tilde/)

# TCL/TK

- [TKE](http://tke.sourceforge.net/)
- [moodit](http://mooedit.sourceforge.net/)
- [msedit](https://sites.google.com/site/msedit/home)


# Windows only

- [nodepad++](https://notepad-plus-plus.org/)
- Crimson or Emerald Editors


- Macros
- Split Views
- Interactive search
- File Browser?
- Smart indent
- Parenthesis matching
- Syntax: PHP, Markdown, C, Java, JavaScript, HTML, C++
- UTF8

Key Bindings: [bindings](http://zzyxx.wikidot.com/key-bindings)

Other CUA stuff: [ergoemacs](https://ergoemacs.github.io/cua-conflict.html)

Others:

- scite [Download](http://www.scintilla.org/SciTEDownload.html)
  It now has a single file exe for Windows.
- editra
- notepadqq
- Geany
- [Scintilla](http://www.scintilla.org/SciTE.html)
   - curses based: [scinterm](http://foicica.com/scinterm/)  
      includes *jinx* which is an example for it.
   - SciTE - the default for Win and Linux.
   - [Others](http://www.scintilla.org/ScintillaRelated.html)
- http://tke.sourceforge.net/index.html
  - TCL based.  Can we use cdk?  Can it be use in linux and windows?
 - [dex](https://github.com/tihirvon/dex)


# Notes

- GUI and TUI, Linux and Windows
- Modeless
- Syntax highlighting
- "Compact"?
- Key recording macros
- Split windows

# Emacs tips

* [make emacs modern](http://ergoemacs.org/emacs/emacs_make_modern.html)
* [single folder autosaves](http://superuser.com/questions/122119/locate-all-emacs-autosaves-and-backups-in-one-folder)
* [backups out of the way](http://emacsredux.com/blog/2013/05/09/keep-backup-and-auto-save-files-out-of-the-way/)
* [emacs tips](http://xenon.stanford.edu/~manku/emacs.html)

# Mote ideas:

* [LinkdMode](http://www.emacswiki.org/emacs/LinkdMode) Paired with "deft"?
* iMenu: `M-x imenu` or:  
  `(add-hook 'c-mode-hook 'imenu-add-menubar-index)`  
  Start typing or use TAB completion to find function defintions.
  See [imenuMode](http://www.emacswiki.org/cgi-bin/wiki/ImenuMode)
* [Predictive Mode](http://www.emacswiki.org/emacs/PredictiveMode)
* Record, play, re-play:  
  `(global-set-key [f10]  'start-kbd-macro)`  
  `(global-set-key [f11]  'end-kbd-macro)`  
  `(global-set-key [f12]  'call-last-kbd-macro)`
* Selective display:  
  `M-1 C-x $` to activate  
  `C-x $` to go back  
  Or create shortcuts:

    (defun jao-toggle-selective-display ()
        (interactive)
        (set-selective-display (if selective-display nil 1)))
    (global-set-key [f1] 'jao-toggle-selective-display)

* * *

    (setq cua-enable-cua-keys nil)
    (setq cua-highlight-region-shift-only t) ;; no transient mark mode
    (setq cua-toggle-set-mark nil) ;; original set-mark behavior, i.e. no transient-mark-mode
    (cua-mode)
