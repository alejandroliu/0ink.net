---
title: Ansible Custom Modules
date: "2025-09-15"
author: alex
tags: ansible, configuration, storage, setup, cloud, library, directory, python, integration,
  scripts, github, application, alpine, linux, tools, sample, information
---
[toc]

![ansible logo]({static}/images/2026/ansible_logo2.png)

# Intro

Ansible is at its best when it lets you declare *what* a system should look like, not
micromanage *how* to get there. Its built-in modules cover most common UNIX configuration
tasks, such as editing files, managing services, installing packages, etc.  

However, some scenarios demand more than that. For example, when configuring storage subsystems,
orchestrating complex workflows, or dealing with edge cases that require precise command
execution, playbooks alone can get messy fast.

That’s where custom modules come in. They let you encapsulate logic, handle complexity cleanly,
and keep your roles declarative and maintainable. Whether you're scripting disk array setup
or wrapping a cloud API call, writing your own module gives you control, clarity, and reusability.


# What is a module

![modules]({static}/images/2026/ansible-modules/modules.png)


At the heart of Ansible’s automation engine is the **module**.  Modules are standalone,
reusable script that performs a specific task. Modules are the building blocks behind
nearly every Ansible action, whether you're installing packages, managing users, configuring
services, or interacting wiht other resources.

Each module defines a clear interface: it accepts arguments, executes logic, and returns
structured output (usually as JSON) back to Ansible.
Modules are executed by Ansible on behalf of the user, and can interact with the target system,
an API, or other resources depending on the task.

# Where to store modules

When you write your own Ansible module, you have a few options for where to place it,
depending on how you want to organize and reuse it:

## Inside a Role

You can store the module in a role’s `library/` directory:
```
roles/
  my_role/
    library/
      my_module.py
```
Ansible automatically loads modules from this path when the role is used in a playbook.
This is ideal for role-specific logic that doesn't need to be shared across multiple projects.

## Inside a Collection

For broader reuse and better packaging, custom modules can live inside a collection:
```
collections/
  ansible_collections/
    my_namespace/
      my_collection/
        plugins/
          modules/
            my_module.py
```
This structure allows you to version, distribute, and document your module cleanly. It also
integrates with Ansible Galaxy and `ansible-galaxy install`.

## Custom Path via `ansible.cfg` or Environment Variable

If you’re testing or prototyping, you can place your module in any directory and tell Ansible
where to find it by setting:
```ini
[defaults]
library = ./custom_modules
```
Or by exporting the `ANSIBLE_LIBRARY` environment variable:
```bash
export ANSIBLE_LIBRARY=./custom_modules
```

When Ansible runs a task that uses your module, it searches these paths in order—starting
with role-local `library/`, then collection plugins, then any configured custom paths. Once
found, the module is copied to the target host (unless you’ve delegated execution to
`localhost`) and executed with arguments passed via a temporary JSON file.


# Writing modules

When writing custom Ansible modules, **Python** is the primary and officially supported
language. It's tightly integrated with Ansible's internals and benefits from the
`AnsibleModule` helper class, which simplifies argument parsing, error handling, and
JSON output.

That said, **other languages can technically be used**, but with caveats:

## Recommended: Python
- Full support via `ansible.module_utils.basic.AnsibleModule`
- Access to Ansible’s plugin APIs and utilities
- Clean integration with roles, collections, and documentation
- Easy to test and debug using `ansible-test`

## Possible but Uncommon: Other Languages
You can write modules in **any language** that:
- Can read JSON input from a temporary file.
- Can write JSON output to `stdout`
- Can exit with a proper return code

## Using Shell script

![bash logo]({static}/images/2026/ansible-modules/full_colored_dark_sm.png)


Using Shell over the recommended Python for Ansible modules may be a better
fit for:

1. Re-using existing Shell scripts \
   If you've built up a library of reliable shell scripts over time, reusing that logic
   inside Ansible modules saves effort and reduces risk. You don't need to reimplement or
   debug complex workflows in Python when they already work in shell.
2. Target Systems Don’t Have Python \
   Minimalist systems—like Alpine Linux, embedded devices, or hardened containers—often lack
   Python by default. Shell is universally available, making it the most portable option for
   modules that need to run directly on the managed node.
3. Closer to the System \
   Shell is ideal for tasks that interact directly with system utilities: `nft`, `ip`, `vgcreate`,
   `mount`, `systemctl`, and so on. These tools are designed to be used from the shell, and
   wrapping them in Python often adds unnecessary complexity.
4. Fast Prototyping \
   Shell scripts are quick to write, test, and iterate. If you’re building a module for a
   specific role or environment, shell lets you move fast without worrying about Python
   packaging, dependencies, or module APIs.
5. Minimal Dependencies \
   Shell modules don't require external libraries or Python environments. Tools like `jq` can
   help with, but that can be optional for simple use cases.

Shell isn't ideal for everything—error handling, argument validation, and testing are more
limited than in Python, but for infrastructure tasks that are already shell-native, it's often
the most efficient and maintainable choice.


# Sample Shell module

```bash
#!/bin/sh
. "$1"

# something happens here

jq -Mn '$ARGS.named' \
	--argjson changed false \
	--arg msg "Hello world" \
	--argjson ansible_facts "$(jq -n '$ARGS.named' \
	  --arg uptime "$(uptime)"
	)" \
	--arg input "$(cat "$1")"

```

This is a sample skeleton file, which does nothing but is a complete Ansible module.

* `. "$1"` \
  Parses the input parameters.  By default, Ansible assume legacy mode, so we can just
  source the input file as it will contain key=value pairs. \
  This means that simple flat parametes can be passed directly.  Use `WANT_JSON` for
  more complex structures, but this adds a dependancy on `jq` for the JSON parsing.
* `jq ...` \
  This generates a JSON response.\
  While we are using `jq` to generate the JSON response, this is not necessary.  As
  long as you output valid JSON, you can do it simply with shell code, for example:
  ```bash
  echo '{ "changed": false }'
  ```
  The response should at least contain:
  * `changed` : boolean, `true` or `false` depending on the outcome of the script.

In the example, we are also returning:

* `msg` : Most modules seem to return this explaining what happened.
* `ansible_facts` : Used for [facts modules][facmod] to return information on the host.

Other return values:

* `failed` : boolean, \
  return `true` if the task failed.
* `skipped`: boolean,
  return `true` if the task was skipped.
  
My convention is that `failed` is when there was an error, whereas `skipped` is more for
when the task can not be executed.

For example, typically I use `skipped` when implementing _check mode_.  Very often
a play would have a task that installs package dependancies.  Obviously if we
are running in _check mode_, the package would not be installed.  Rather than
fail the play by returning `failed: true` as normally would do, if the
module is running in _check mode_ I would return `skipped`.

# JSON input

For some scenarios, you may need to pass more complex paramters.  You can 
easily achieve this by declaring your custom module to want JSON:

```bash
#!/bin/sh
# WANT_JSON

echo '{"changed": false}'
```
By having the string `WANT_JSON` around the start of the file, this tells
Ansible that this module accepts JSON input.

# Additional parameters

In addition to the parameters in the playbook, the following parameters
are send to the module:

* `_ansible_check_mode` : boolean, if true, _check mode_ is being used (cli option: `--check`)
* `_ansible_diff` : boolean, if true _diff mode_ is being used (cli option: `--diff`)
* `_ansible_verbosity` : int,  cli options: `-v`, `-vv` or `-vvv`.
* `_ansible_keep_remote_files`: boolean, environment `ANSIBLE_KEEP_REMOTE_FILES=1`.
* `_ansible_version`: str, example: `2.18.8`
* `_ansible_no_log` : boolean
* `_ansible_debug` : boolean
* `_ansible_version`: str, example: `2.18.8`
* `_ansible_module_name`: str 
* `_ansible_syslog_facility` : str
* `_ansible_selinux_special_fs`
* `_ansible_string_conversion_action` : enum
* `_ansible_socket` : null
* `_ansible_shell_executable` : str
* `_ansible_tmpdir` : str
* `_ansible_remote_tmp` : str
* `_ansible_ignore_unknown_opts` : boolean

# check_mode

![dry run]({static}/images/2026/ansible-modules/dryrun.png)

When modules are passed the parameter `_ansible_check_mode=True`, this means the playbook
is running in **dry-run mode**.  See [Ansible check mode][check].

When in check mode, the module must simulate changes without actually applying them to
the system.  Modules that support _check mode_, must report what **would** change or
simply skip execution.

This is useful for:

* Validating playbooks before deployment
* Auditing potential changes
* Testing custom modules or logic safely

# ansible_diff

When modules are passed the parameter `_ansible_diff=True`, it must show the
before-and-after changes, especially those that modify files or configurations.

Typically, this is combined with _check mode_  to preview changes without applying them.

To support this, you must include a `diff` key in the return JSON object:

```json
diff: [{
    "before_header": "/etc/my_config.ini (original)",
    "before": "line1 = old content\n",
    "after_header": "/etc/my_config.ini (original)",
    "after": "line1 = new content\n",
    "prepared": ">>> reload apache",
}]
```
Not shown in the example, but you must return `"changed": true`, otherwise the diff
sets will **not** be processed.

In this example, we are creating a list for the `diff` key.  You can return multiple
`diff` sets.  If you are only returning one (1) diff set, you can simply return it
directly (without wrapping it inside a list).

You can return at least `before`,`after` pair, or a `prepared` key.   Returning
all three is possible.  `before_header` and `after_header` are optional.

Normally I would return `before` and `after` for when configuration files
are being changed.  I would use the `prepared` key for when we are running
commands on the system.   For example, running `mkfs`, `lvcreate`, etc.

# Generating JSON output

![json logo]({static}/images/2026/ansible-modules/json-b.png)

While you can use `echo` statements to generate the JSON output, to simplify things
you can use the `jq` command instead.  Example:

```bash
jq -Mn '$ARGS.named' \
	--argjson changed false \
	--arg msg "Hello world" \
	--argjson ansible_facts "$(jq -n '$ARGS.named' \
	  --arg uptime "$(uptime)"
	)"
```

In this example we are using:

* `-M` or `--monochrome-output` : This prevents `jq` to use ANSI escape sequences
  to colorize its output.
* `-n` or `--null-input` : Skip reading any input
* `'$ARGS.named`' : outputs the arguments specified in the commnad line
* `--argjson key value` : define the _key_ as a valid json _value_.  This can be
  a full json structure, but most commonly is used to define booleans or numbers.
* `--arg key value` : define the _key_ as the string _value_.

# Final thoughts

While Python remains the default language for [Ansible module development][mod-dev], shell
scripting offers a pragmatic alternative, especially in environments where Python isn't readily
available or where existing shell logic is already battle-tested. By understanding how
Ansible passes arguments, handles check and diff modes, and expects structured output, you can
write shell-based modules that integrate cleanly into your automation workflows without
sacrificing clarity or control.

Whether you're managing minimalist systems, reusing hardened scripts, or simply prefer the
transparency of shell, custom modules give you the flexibility to tailor Ansible to your
infrastructure, not the other way around.




 [mod-dev]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html
 [facmod]: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-an-info-or-a-facts-module
 [check]: https://docs.ansible.com/ansible/2.9/user_guide/playbooks_checkmode.html
 [diff]: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html#using-diff-mode
 