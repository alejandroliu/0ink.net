---
title: Lookup Ansible vars from the command line
date: "2025-07-19"
author: alex
tags: ansible
---
This is a **quickie**.  If you want to look-up the value of an Ansible variable from
the command line:

```bash

ansible localhost -m ansible.builtin.debug -a "var=my_variable"
```

