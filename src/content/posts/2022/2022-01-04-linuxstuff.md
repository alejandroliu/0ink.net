---
title: Linux stuff
tags: sudo
---

# Sudoers

Since [sudo][sudo] v1.9, it is possible to use the following
statements:

- `#includedir`
- `@includedir`

This is useful better for adding sudo rules rather than modifying
the `/etc/sudoers` file.

Make sure that the `includedir` statement is the **LAST** entry
in `/etc/sudoers` and the files in the directory:

- names do not contain `.` (dots)
- ownership to `root`:`root` and permission is set to `0440`.

[sudo]: https://www.sudo.ws/
