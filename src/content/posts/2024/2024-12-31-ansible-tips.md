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
  

# Execution order

1. pre_tasks
2. roles (in the order they are listed)
3. tasks
4. handlers (only if notified by a task and before post_tasks)
5. post_tasks


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

# Writing ansible modules in sh

See [Ansible Module architecture](https://docs.ansible.com/ansible/latest/dev_guide/developing_program_flow_modules.html)
for more details.

This documents how to create [Old-style](https://docs.ansible.com/ansible/latest/dev_guide/developing_program_flow_modules.html)
Ansible module.  These are less efficient but are asier to implement in shell script.

[Ansible][aa] playbooks are meant to be declarative in nature.  So for handling more
complex tasks the recommendation is to write modules, which then can be used from a
playbook.  To create a module in shell script, you just need to create a file in your
module's path (ANSIBLE_LIBRARY).   Input parameters are given as a file in "$1".  This
file is formatted as a `source`able file so using:

```bash
. "$1"
````

The return code of the script is used to determine if the module was succesful or 
an error happened.

The output of the script *must* be in JSON format.  And it should contain the following
keys:

- `changed` : boolean indicating if changes were made
- `msg` : optional informational message, particularly useful in an error condition.
- `ansible_facts` : dictionary containing facts that will be added to the playbook run.
  This is optional.

There are additional arguments sent to the script.  These are [internal ansible](https://docs.ansible.com/ansible/latest/dev_guide/developing_program_flow_modules.html#internal-arguments)
arguments.  Worth mentioning are:

- `_ansible_no_log` (boolean) : do not log output.  Used to keep sensitive strings from logging.
- `_ansible_debug` (boolean) : debugging
- `_ansible_diff` (boolean) : Running in diff mode.
- `_ansible_check_mode` (boolean) : Running in check mode.

## Check mode

If `_ansible_check_mode` is set to `True`, the user is running the playbook with the
`--check` flag.  Modules should only show that changes would be made, without making
any actual changes.

More details [here](https://medium.com/opsops/understanding-ansibles-check-mode-299fd8a6a532)

## Diff mode

If `_ansible_diff` is set to `True`, the user is running the playbook with the `--diff`
flag.  Modules that support this should add a key named `diff` with either:

1. two keys, `before` and `after`.  This contains the contents before and after the change.
2. single `prepared` key.  This contains a list with a textual descriptions of the changes
   to be made.

See [article](https://blog.devops.dev/writing-ansible-modules-with-support-for-diff-mode-cae70de1c25f)

# Writing Ansible Action Plugins

Modules described earlier, run on the managed node.  While they can return data to the control
node, sometimes is necessary to do some preparatory work on the control node before
calling a Module proper.  This is done using [Action Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#action-plugins)

Essentially, action plugins let you integrate local processing and local data with module functionality.

To create an action plugin, create a new class with the Base(ActionBase) class as the parent:

```python
from ansible.plugins.action import ActionBase

class ActionModule(ActionBase):
    pass

```

From there, execute the module using the `_execute_module` method to call the original module.
After successful execution of the module, you can modify the module return data.

```python
module_return = self._execute_module(module_name='<NAME_OF_MODULE>',
                                     module_args=module_args,
                                     task_vars=task_vars, tmp=tmp)
```

A simple example template:

```python
#!/usr/bin/python
# Make coding more python3-ish, this is required for contributions to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase
from datetime import datetime


class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        result = super(ActionModule, self).run(tmp, task_vars)
        module_args = self._task.args.copy()
        module_return = self._execute_module(module_name='setup',
                                             module_args=module_args,
                                             task_vars=task_vars, tmp=tmp)
        result.update(module_return)
        return result
```


## Transferring data from an ActionPlugin

So you need to copy a large file from the control node to the managed node
in an Action Plugin.  To do this you need to declar in your class:

```python
TRANSFERS_FILES = True
```

Next in your Action implementation, you can use this command to create 
temporary file:

```python
tmp_src = self._connection._shell.join_path(self._connection._shell.tmpdir, 'archive.zip')
```
Then you can copy bytes:

```python
self._transfer_data(tmp_src, bytes_object)
```
or copy a file:

```python
self._transfer_file(local_file, tmp_src)
```

A complete example:

```python
#!/usr/bin/python

# Make coding more python3-ish, this is required for contributions to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type


from ansible.plugins.action import ActionBase
from ansible.errors import AnsibleActionFail, AnsibleError

class ActionModule(ActionBase):
  TRANSFERS_FILES = True

  def run(self, tmp=None, task_vars=None):
    result = super(ActionModule, self).run(tmp, task_vars)

    # Get the arguments passed to the action plugin
    src = self._task.args.get('src', '')
    if len(src) == 0:
      raise AnsibleActionFail('Missing or empty src parameter',result=result)

    # Copy archive to remote/managed node:
    try:
      tmp_src = self._connection._shell.join_path(self._connection._shell.tmpdir, 'archive.zip')
      self._transfer_file(src, tmp_src)
    except AnsibleError as e:
      raise AnsibleActionFail(to_text(e))

    return result



```

# Using Ansible playbooks through SSH bastion hosts/jump servers

There are two approaches:

## Inventory vars

The first way to do it with Ansible is to describe how to connect through the proxy server
in Ansible's inventory. This is helpful for a project that might be run from various workstations
or servers without the same SSH configuration (the configuration is stored alongside the
playbook, in the inventory).

Example Inventory:

```ini
[proxy]
bastion.example.com

[nodes]
private-server-1.example.com
private-server-2.example.com
private-server-3.example.com


[nodes:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -p 2222 -W %h:%p -q username@bastion.example.com"'

```

This sets up an SSH proxy through bastion.example.com on port 2222 (if using the default port,
22, you can drop the port argument). The -W argument tells SSH it can forward stdin and stdout
through the host and port, effectively allowing Ansible to manage the node behind the
bastion/jump server.

The important config line is `ansible_ssh_common_args`, which adds the relevant options to
the ansible `ssh` command.  A few notes on the options:

Recent SSH versions could just use:

```ini
ansible_ssh_common_args='-J username@bastion.example.com:2222"'
```

## SSH config

The alternative, which would apply the proxy configuration to all SSH connections on a
given workstation, is to add the following configuration inside your `~/.ssh/config` file:

```text

Host private-server-*.example.com
   ProxyJump user@bastion:2222
```

Ansible will automatically use whatever SSH options are defined in the user or global SSH
config, so it should pick these settings up even if you don't modify your inventory.

This method is most helpful if you know your playbook will always be run from a server or
workstation where the SSH config is present.  Also, this applies to normal `ssh` invokations
so if you also use the `ssh` and related utilities directly, then, htey will use the 
same configuration.

## TCP Tunneling

These options assume that the bastion host has TCP Tunneling/Forwarding enabled.  If your
bastion host has this feature **disabled**, you can replace the `ProxyJump` with
proxy command:

```text
  ProxyCommand ssh user@bastion nc %h %p
```

This replaces the `-W` option with the `nc` (netcat) command.


Source: https://www.jeffgeerling.com/blog/2022/using-ansible-playbook-ssh-bastion-jump-host


# Report no changes when running a script

Running a script always assume that it makes changes.

Using scripts is *not recommenteded* because it is just as easy to convert the script into
a proper [Ansible][aa] module.  Doing so makes it also possible to:

- Return ansible facts
- Report change status
- Support __check__ and __diff__ modes.

Regardless, this is an example:

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

## Adding check_mode to a script

In addition, it is actually possible to support `check_mode` in a script.  You need to:

- Pass the appropriate settings to your script indicating to it that it is in `check_mode`. \
  This can be done by adding a check for the `ansible_check_mode` variable in a Jinja2 template.
- Set-up the task so that it will also execute in `check_mode` by adding the tag: `check_mode: false`
  to it.
- Example:
  ```yaml
  - name: "Apply config to {{domu_name}}"
    command: |
      xop cfg --no-change-rc=127 {% if ansible_check_mode %}--dry-run{% endif %} {{domu_name}}
    register: res
    failed_when: res.rc != 0 and res.rc != 127
    changed_when: res.rc != 127
    check_mode: false
  ```
- In this example, the `xop cfg` command gets executed regardless if `check_mode` is on or off. 
- The script then is passed the `--dry-run` option if `ansible_check_mode` is on.  So the script
  will not make any actual changes to the system.

Scripts:

- [Custom script action](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2024/ansible/action_plugins/script.py)
- [Custom command module](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2024/ansible/modules/command.py)


  

  [aa]: https://www.ansible.com/

