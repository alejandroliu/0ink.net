---
title: Ansible Custom Action Plugins
date: "2025-09-13"
author: alex
tags: python, directory, github, ansible, configuration, application, storage, remote,
  information, settings, setup
---
[toc]

This is a continuation to my [[2026-05-01-ansible-custom-modules.md|Ansible custom modules]] article.

Action plugins let you integrate local processing and local data with module functionality.

At the time of this writing, documentation I could find was
[Developing plugins - Action plugins][action-dev] which was somewhat out-of-date.

![ansible logo]({static}/images/2026/ansible_logo2.png)

# Introduction

Ansible **action plugins** are Python-based extensions that run on the **control node**,
allowing you to intercept and modify the behavior of tasks before they're executed on
remote hosts. Unlike regular modules, which run remotely, action plugins give you local
control over task execution logic, argument manipulation, and result handling.

They’re especially useful when:
- You need to **preprocess arguments** or **include local data** before calling a module.
- You want to **combine multiple modules** into a single task.
- You’re working in environments with **limited remote capabilities**, or need
  **local-only logic**.

Each plugin is a class that inherits from `ActionBase`, and typically overrides the
`run()` method. Inside this method, you can use `_execute_module()` to call the actual
module, or bypass it entirely for local-only tasks.

# Motivation

While building an Ansible role for nftables, incorporating ideas from
[Frzk’s nftables role](https://github.com/Frzk/ansible-role-nftables)
and
[kormat’s iptables-apply](https://github.com/kormat/ansible-iptables-apply)
to handle recovery from new rulesets that would break or hang Ansible's
control connection it became challeging to use YAML to manage control flow,
error handling, and connection state.

![netfilter logo]({static}/images/2026/ansible-actions/nflogo.png)


By writing a custom action plugin, I could:
- Run logic locally on the control node
- Use Python to apply rules and handle failures gracefully
- Keep playbooks declarative, while isolating recovery logic in code

This gives a cleaner, more robust way to experiment with firewall changes without
compromising automation reliability.


# Where to place Action Plugins

Custom action plugins can be placed in several locations depending on your project structure
and scope:

## Role or Collection scope

- **Inside a role**:  
  Place the plugin in `roles/<role_name>/action_plugins/`.  
  This makes it available only when the role is used.
- **Inside a collection**:  
  Use `plugins/action/` within your collection directory.  
  This is ideal for distributing reusable plugins.

## User or System Scoped
- **User-level plugin directory**:  
  `~/.ansible/plugins/action/`  
  This makes the plugin available across all playbooks for the current user.

- **System-level plugin directory**:  
  `/usr/share/ansible/plugins/action/`  
  Useful for global availability across users and projects.

![plugins]({static}/images/2026/ansible-actions/plugins.png)

## Configuring Plugin Paths

To make Ansible recognize custom plugin locations, you can configure the plugin path:

1. **Via `ansible.cfg`** \
   Add or modify the following in your `ansible.cfg` file:
   ```ini
   [defaults]
   action_plugins = ./action_plugins:~/.ansible/plugins/action:/usr/share/ansible/plugins/action
   ```
   - Paths are colon-separated.
   - Relative paths (like `./action_plugins`) are resolved from the playbook directory.
2. **Via Environment Variable** \
   Set the `ANSIBLE_ACTION_PLUGINS` environment variable:
   ```bash
   export ANSIBLE_ACTION_PLUGINS=./action_plugins:~/.ansible/plugins/action
   ```
   This overrides the config file setting and is useful for temporary or dynamic setups.

You can inspect your current plugin paths using `ansible-config dump | grep ACTION_PLUGIN_PATH`.

# Basic layout

```python
#!/usr/bin/python
# Make coding more python3-ish, this is required for contributions to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

# Base class
from ansible.plugins.action import ActionBase

class ActionModule(ActionBase):
  def run(self, tmp=None, task_vars=None):
    if task_vars is None: task_vars = dict()
    result = super().run(tmp, task_vars)
    del tmp  # tmp no longer has any effect

    # Do something here...

	return result
    
```

This is the simplest action plugin.  It declares itself as a sub-class
of `ActionBase`, and populates the `task_vars` structure with values
and initializes `result` with some defaults.

# Error handling

![errors]({static}/images/2026/ansible-actions/errors.png)


Ansible leverages Python's exception system to handle errors cleanly. Within your custom
action plugin, you can raise exceptions to signal failure conditions. Start by importing
the relevant classes:

```python
from ansible.errors import AnsibleError, AnsibleFileNotFound, AnsibleAction, AnsibleActionFail
```

You can also use Python’s built-in [exceptions][exceptions] if preferred.

To raise an error:

```python
raise AnsibleFileNotFound('thisfile.txt')
```

By default, Ansible displays a simplified error message. To see the full
**stack trace**, run your playbook with increased verbosity:

```bash
ansible-playbook playbook.yml -vvv
```

This is especially useful when debugging plugin logic or tracing failures deep in
the call stack.


# Diagnostics and Verbose output

![diagnostics]({static}/images/2026/ansible-actions/diagnostics.png)

Custom action plugins often need to communicate status or debug information. Ansible
provides the `Display` class for structured output:

```python
from ansible.utils.display import Display
display = Display()
```

You can then emit messages based on verbosity level:

```python
if display.verbosity > 1:
    display.display('Verbose message')
```

Or use the built-in verbosity helpers:

```python
display.v('Level 1 verbosity')
display.vv('Level 2 verbosity')
display.vvv('Level 3 verbosity')
```

Control verbosity from the command line using `-v`, `-vv`, or `-vvv`. This lets users opt
into more detailed diagnostics without cluttering standard output.

# Run-time environment

![rte]({static}/images/2026/ansible-actions/rte.png)

When writing custom action plugins, it is often useful to inspect the execution context; 
whether you're debugging behavior, adapting to playbook settings, or resolving file paths.
Ansible exposes several runtime variables and constants that help you do just that.

Start by importing the constants module:

```python
import ansible.constants as C
```

Here are some useful runtime indicators and paths:

![context]({static}/images/2026/ansible-actions/context.png)


## Execution Context Flags
- `self._task.diff`  \
  Indicates if the task is running in **diff mode** (`--diff`).
  
- `self._task.check_mode`  \
  True if the task is running in **check mode** (`--check`).

- `self._task.no_log`  \
  True if the task or play has enabled the `no_log` flag.

- `self._task.role` \
  A string with the current role, otherwise None.

## Path Resolution
- `self._task.get_search_path()`  \
  Returns the search path used to resolve relative file names.


- `C.DEFAULT_ROLES_PATH`  \
  Default path(s) where Ansible looks for roles.

- `C.COLLECTIONS_PATHS`  \
  Path(s) used to locate collections.

- `C.PLAYBOOK_DIR`  \
  Directory of the current playbook being executed.

## Remote File Cleanup

- `C.DEFAULT_KEEP_REMOTE_FILES`  
  Controls whether temporary files on remote hosts are cleaned up.  
  You can enable this by setting the environment variable:

  ```bash
  export ANSIBLE_KEEP_REMOTE_FILES=1
  ```

These variables are especially helpful when building plugins that need to behave
differently based on execution mode or when resolving paths dynamically.


# Accessing task parameters

Action plugins receive task parameters as a dictionary via `self._task.args`. These are the
arguments defined in the playbook for the task invoking your plugin.

```python
params = self._task.args
```

You can interact with this dictionary using standard Python methods like `.get()` or direct
key access.

> Note: Any parameters containing Jinja2 templates are **rendered before** the plugin is
> executed. This means you’ll receive fully evaluated values, not raw template strings.

This makes it easy to write plugins that behave predictably, without needing to manually
resolve templating logic.

# More Task Context via `task_vars`

In addition to parameters passed directly to your action plugin via `self._task.args`,
Ansible provides a broader context through the `task_vars` dictionary. This contains
**all variables available to the task at runtime**, including:

- Inventory & Host Variables
  - Variables from `host_vars` and `group_vars`
  - `inventory_hostname`, `group_names`, `ansible_play_hosts`
- Facts
  - Gathered facts like `ansible_distribution`, `ansible_interfaces`, `ansible_facts`
  - Custom facts from `setup` or `set_fact`
- Plabook & Role Context
  - Variables defined in `vars`, `vars_files`, or `vars_prompt`
  - Role defaults and vars
  - Tags: `ansible_run_tags`, `ansible_skip_tags`
- Execution Flags
  - `ansible_check_mode`: Whether the task is running in check mode
  - `ansible_diff_mode`: Whether diff mode is enabled
  - `ansible_dependent_role_names`: List of dependent roles
- User-defined Variables
  - Variables passed via `--extra-vars`
  - Any custom values defined earlier in the play

From your `run` method:

```python
hostname = task_vars.get('inventory_hostname')
os_family = task_vars.get('ansible_os_family')
debug_flag = task_vars.get('my_custom_flag', False)
raw_value = task_vars.get('my_inventory_value')
```

Unlike `self._task.args`, which contains pre-rendered values, entries in `task_vars` may
still include **raw Jinja2 expressions**, especially when variables are defined in inventory
or playbooks using templating syntax.

To evaluate these expressions inside your plugin, use the templar:

```python
my_value = self._templar.template(task_vars.get('my_inventory_value'))
os_family = self._templar.template(task_vars.get('ansible_os_family'))
```

This ensures your plugin works with fully resolved values, allowing it to behave consistently
regardless of how variables were defined.

> You can also use `template()` on dictionaries or lists to resolve nested structures.

# Implementing _check mode_

![dry run]({static}/images/2026/ansible-modules/dryrun.png)

Similar to custom modules, action plugins support _check mode_.  When the user passes
the `--check` flag, this will set the flag `self._task.check_mode` to True.  This
means the playbook is running in **dry-run mode**.  See [Ansible check mode][check].

When in check mode, the Action plugin must simulate changes without actually applying them to
the system.  Modules that support _check mode_, must report what **would** change or
simply skip execution.

This is useful for:

* Validating playbooks before deployment
* Auditing potential changes
* Testing custom modules or logic safely

# Implementing _diff mode_

![diff]({static}/images/2026/ansible-actions/diff.png)


_Check mode_ is often paired with the `--diff` command line argument.  This 
will set the `self._task.diff` to True.  When this is the case, Action
plugins must show the before-and-after changes, especially those that modify files
or configurations.

A quick example:
```python

if self._task.diff and result['changed']:
  if not 'diff' in result: result['diff'] = list()
  result['diff'].append({
        'before_header': 'hdr1 (original)',
        'before': 'before\n',
        'after_header': 'hdr1 (updated)',
        'after': 'after\n',
        'prepared': '>>> Preparation',
  })

```

In this example, we are creating a list for the `diff` key.  You can return multiple
`diff` sets.  If you are only returning one (1) diff set, you can simply return it
directly (without wrapping it inside a list).

You can return at least `before`,`after` pair, or a `prepared` key.   Returning
all three is possible.  `before_header` and `after_header` are optional.

Normally I would return `before` and `after` for when configuration files
are being changed.  I would use the `prepared` key for when we are running
commands on the system.   For example, running `mkfs`, `lvcreate`, etc.

# Template Rendering

![template]({static}/images/2026/ansible-actions/tmpl.png)

When rendering templates from files within an action plugin, the following
pattern ensures correctness and compatibility with Ansible’s templating
engine:

- Import the required dependency:
  ```python
  from ansible.template import Templar
  ```
- Locate the template file:
  ```python
  template_path = self._task.args.get('template')
  srcfile = self._find_needle('templates', template_path)
  ```
  This searches for the template in the configured `templates/` directories and
  resolves the full path.
- Adjust the loader's basedir to support `{% include %}` and relative paths:
  ```python
  old_basedir = self._loader.get_basedir()
  self._loader.set_basedir(os.path.dirname(srcfile))
  ```

- Render the template:
  ```python
  with open(srcfile, 'r') as fp:
      template = fp.read()

  tp = Templar(loader=self._loader, variables=task_vars)
  rendered = tp.template(template)
  ```

- Restore the original basedir to avoid side effects:
  ```python
  self._loader.set_basedir(old_basedir)
  ```

Notes:

- Always reset the loader's basedir after rendering to prevent unexpected behavior
  in subsequent tasks.
- Using `Templar` directly gives you full control over variable resolution and
  template rendering, including support for Ansible-specific filters and syntax.

# Calling Modules from Action Plugins

Action plugins often serve as orchestrators, combining logic, templating, and
conditional behavior before delegating actual work to modules. To invoke a module
from within an action plugin, use the `_execute_module()` method, which handles
serialization, transport, and return parsing.

![calling module]({static}/images/2026/ansible-actions/modcall.png)


## Example: Delegating to a Custom Module

```python
mod_args = {
    'dest': dest,
    'files': '\n'.join(flist),
    'ro_check': ro_check if ro_check else '',
}

mod_return = self._execute_module(
    module_name='mab_prune',
    module_args=mod_args,
    task_vars=task_vars
)
```

## Key Concepts

- **`module_name`**: This should match the name of the module file (without `.py`)
  and be resolvable via the plugin loader. If you're calling a module from your own
  collection, use the fully qualified name (e.g. `my_namespace.my_collection.mab_prune`).
- **`module_args`**: A dictionary of arguments passed to the module. These should be
  flat and serializable.  Avoid nested structures unless your module explicitly supports
  them.
- **`task_vars`**: Pass the current task variables to ensure proper templating and
  context resolution. This includes facts, host vars, and role defaults.

## Return Value

The result of `_execute_module()` is a dictionary that mimics the return from a normal
module execution. It includes keys like:

- `changed`: Boolean indicating whether the module made changes.
- `failed`: Boolean indicating failure.
- `msg`: Optional message string.
- Any custom return values defined by your module.

You can use this return to control flow, emit diagnostics, or raise errors:

```python
if mod_return.get('failed'):
    raise AnsibleActionFail("Module execution failed: %s" % mod_return.get('msg'))
```

## Best Practices

- **Avoid side effects before module execution**: If your plugin modifies state before
  calling the module, ensure those changes are reversible in case the module fails.
- **Respect check mode**: If your plugin supports check mode, ensure the module you're
  calling does too—or skip execution when `self._play_context.check_mode` is `True`.
- **Use `Display.vvv()` for debugging**: Log the module arguments and return values
  at verbosity level 3+ to aid troubleshooting.

# Return values

Action plugins return a dictionary that mirrors the structure of module results.
This ensures consistency across tasks and allows Ansible to interpret outcomes
correctly.

## Common Keys

- **`changed`** (`bool`): Indicates whether the task made changes to the system.
  Set this to `True` only when a state transition occurred.
- **`failed`** (`bool`): Signals task failure. If `True`, Ansible halts execution
  unless `ignore_errors` is set.
- **`msg`** (`str`): A human-readable message describing the outcome or error.
- **`skipped`** (`bool`): Marks the task as intentionally skipped, often used with
  conditional logic.
- **`invocation`** (`dict`): Automatically populated metadata about how the plugin
  was called. Use `self._get_invocation(task_vars)` to include it.

## Custom Return Values

You can include additional keys specific to your plugin or module logic:

```python
return {
    'changed': True,
    'pruned_files': pruned,
    'skipped_files': skipped,
    'msg': "Pruned %d files" % len(pruned),
    'invocation': self._get_invocation(task_vars),
}
```

For more common return values see [Common Return values][results].

# Conclusion

![ninja]({static}/images/2026/ansible-actions/ninja.png)

Action plugins offer deep control over task execution, making them ideal for
implementing custom logic, enforcing policy, and handling edge cases like
connection loss or remote cleanup. But with that control comes complexity;
especially around templating, context flags, and runtime behavior.

This article outlined practical patterns for building reliable, maintainable
plugins: from placement and layout to diagnostics, error handling, and module
delegation. The goal is not just flexibility, but **predictability** -- plugins
that behave consistently across environments, expose their decisions clearly,
and fail gracefully when needed.

In automation, predictability builds trust. And trust is what lets teams move
fast without breaking things.



  [action-dev]: https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#action-plugins
  [exceptions]: https://docs.python.org/3/library/exceptions.html
  [check]: https://docs.ansible.com/ansible/2.9/user_guide/playbooks_checkmode.html
  [diff]: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html#using-diff-mode
  [results]: https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html
 