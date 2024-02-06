---
title: Ansible Snippets
date: "2024-02-06"
author: alex
---
[toc]

***

# Report no changes when running a script

```yaml
tasks:

- name: Exec sh command
  shell:
    cmd: "echo ''; exit 254;"
  register: result
  failed_when: result.rc != 0 and result.rc != 254
  changed_when: result.rc != 254
```

I have customized `command` module and the `script` action plugin to simplify these
three lines of code into a single line.

- LINK: custom command module
- LINK: custome action plugin

# Create a file without external template

```yaml
- name: Create a customized file
  copy:
    content: |
      Hello {{ who }},
      This file was created by Ansible.
    dest: /path/to/your/file.txt
  vars:
    who: "World"
```




