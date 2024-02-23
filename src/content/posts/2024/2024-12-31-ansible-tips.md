---
title: Ansible Snippets
date: "2024-02-06"
author: alex
---
[toc]

***

# Bootstraping

- Create a default config file: \
  `ansible-config init --disabled > ansible.cfg`
- Createa new ansible role directory: \
  `ansible-galaxy init --init-path roles _role-name_` \
  This creates the directory _role-name_ in the `roles` directory.
  

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
three lines of code into a single line.  So the previous example becomes:

```yaml
tasks:

- name: Exec sh command
  shell:
    cmd: "echo ''; exit 254;"
  no_change_rc: 254
```

Scripts:

- [Custom script action](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2024/ansible/action_plugins/script.py)
- [Custom command module](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2024/ansible/modules/command.py)

# Create a file without external template

Normally you can use the [template module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
to send a Jinja2 templated file to the managed host.  This requires that the
Jinja2 template be stored in its own file.  Some times I find it more convenient
to place the template directly into the YAML file.

This can be achieved using the [copy module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
and the [content](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameter-content)
parameter.  Example:

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

# Creating inventory script

When specifying inventories in ansible, an executable file can be specified.
This will be executed to generate the inventory.  It takes the following
command line arguments:

- `script --list` \
  Returns a JSON formatted inventory.  Example:
  ```json
  {
      "group001": {
          "hosts": ["host001", "host002"],
          "vars": {
              "var1": true
          },
          "children": ["group002"]
      },
      "group002": {
          "hosts": ["host003","host004"],
          "vars": {
              "var2": 500
          },
          "children":[]
      }
      "_meta": {
          "hostvars": {
              "host001": {
                  "var001" : "value"
              },
              "host002": {
                  "var002": "value"
              }
          }
      }
  }
  ```
  The output should be a JSON object containing all the groups to be managed as
  dictionary items.  Each group's value should be either an object containing a
  list of each host, any child groiups, and potential group variables, or simply
  a list of hosts.  Empty elements of a group can be omitted. \
  An optional `_meta` block can be added to contain host specific variables.  If
  this is omitted, the `--host` command line argument is used to query host variables.
  
- `script --host` _hostname_ \
  Where _hostname_ is a host from the `--list`.  The script should return
  either an empty JSON object, or a JSON dictionary containing meta varaibles specific
  to the host.  Example:
  ```json
  {
      "VAR001": "VALUE",
      "VAR002": "VALUE"
  }
  ```

Other arguments are allowed but [ansible][aa] will not use them.

See [Inventory scripts](https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#developing-inventory-scripts)
for more details.

You can use the [ansible-inventory](https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html#ansible-inventory)
command to see what [ansible][aa] will process for its inventory.


  [aa]: https://www.ansible.com/

