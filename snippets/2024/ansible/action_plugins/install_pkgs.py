#
# Based on the ansible.builtin.script module
# Original file is part of Ansible
# (c) 2012, Michael DeHaan <michael.dehaan@gmail.com>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import shlex

from ansible.errors import AnsibleError, AnsibleAction, _AnsibleActionDone, AnsibleActionFail, AnsibleActionSkip
from ansible.executor.powershell import module_manifest as ps_manifest
from ansible.module_utils.common.text.converters import to_bytes, to_native, to_text
from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):
  TRANSFERS_FILES = True

  def run(self, tmp=None, task_vars=None):
    ''' handler for file transfer operations '''
    if task_vars is None:
      task_vars = dict()

    result = super(ActionModule, self).run(tmp, task_vars)
    del tmp  # tmp no longer has any effect

    # Get the arguments passed to the action plugin
    tmp_pkgs = self._task.args.get('pkgs', [])
    if isinstance(tmp_pkgs,str):
      tmp_pkgs = tmp_pkgs.split()
    if len(tmp_pkgs) == 0:
      raise AnsibleActionFail('Missing or empty pkgs parameter',result=result)

    # Get the "installed_pkgs" variable if it exists, otherwise create an empty list
    inst_pkgs = task_vars.get('installed_pkgs', [])

    # Remove SSH round-trips if we already installed this pkg in this run
    new_pkgs = []
    for p in tmp_pkgs:
      if not (p in inst_pkgs or p in new_pkgs): new_pkgs.append(p)
    if len(new_pkgs) == 0:
      return {
        "changed": False,
        "info": "nothing to be done"
      }

    # Add the new packages to the installed_pkgs list
    inst_pkgs.extend(new_pkgs)
    result.update({"ansible_facts": {"installed_pkgs": inst_pkgs}})


    try:
      cmd = self._task.args.get('cmd',
                task_vars.get('mab_managed_pkgs_install_cmd',
                    os.path.join(os.path.dirname(__file__),
                                'install_pkgs.sh')))

      # Split out the script as the first item in cmd using
      # shlex.split() in order to support paths and files with spaces in the name.
      # Any arguments passed to the script will be added back later.
      cmd = to_native(cmd)
      parts = [to_text(s, errors='surrogate_or_strict') for s in shlex.split(cmd.strip())]
      source = parts[0]
      result['cmd'] = cmd

      # ~ # Support executable paths and files with spaces in the name.
      # ~ executable = new_module_args['executable']
      # ~ if executable:
          # ~ executable = to_native(new_module_args['executable'], errors='surrogate_or_strict')
      # ~ try:
          # ~ source = self._loader.get_real_file(self._find_needle('files', source), decrypt=self._task.args.get('decrypt', True))
      # ~ except AnsibleError as e:
          # ~ raise AnsibleActionFail(to_native(e))

      if self._task.check_mode:
        result['changed'] = False
        raise AnsibleActionSkip('Check mode is not supported for this task.', result=result)

      # now we execute script, always assume changed.
      result['changed'] = True

      # transfer the file to a remote tmp location
      tmp_src = self._connection._shell.join_path(self._connection._shell.tmpdir,
                                                  os.path.basename(source))

      # Convert cmd to text for the purpose of replacing the script since
      # parts and tmp_src are both unicode strings and raw_params will be different
      # depending on Python version.
      #
      # Once everything is encoded consistently, replace the script path on the remote
      # system with the remainder of the cmd. This preserves quoting in parameters
      # that would have been removed by shlex.split().
      target_command = to_text(cmd).strip().replace(parts[0], tmp_src)

      self._transfer_file(source, tmp_src)

      # set file permissions, more permissive when the copy is done as a different user
      self._fixup_perms2((self._connection._shell.tmpdir, tmp_src), execute=True)

      # add preparation steps to one ssh roundtrip executing the script
      env_dict = dict()
      env_string = self._compute_environment_string(env_dict)

      script_cmd = ' '.join([env_string, target_command, 'add', *new_pkgs])
      script_cmd = self._connection._shell.wrap_for_exec(script_cmd)

      result.update(self._low_level_execute_command(cmd=script_cmd, sudoable=True))

      no_change_rc = 127
      if 'rc' in result:
        result['orc'] = result['rc'] # Record the original return code...
        if result['rc'] == no_change_rc:
          result['changed'] = False
          result['rc'] = 0 # Otherrwise it fails!
        elif result['rc'] != 0:
          raise AnsibleActionFail('non-zero return code')

    except AnsibleAction as e:
        result.update(e.result)
    finally:
        self._remove_tmp_path(self._connection._shell.tmpdir)

    return result
