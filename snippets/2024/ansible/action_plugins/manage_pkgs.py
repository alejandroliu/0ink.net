#
# This plugin action module implements a simple "managed pkg"
# approach.
#
# Specifically, this action lets you register pkgs that will be
# "managed".
#

from ansible.plugins.action import ActionBase

class ActionModule(ActionBase):
  def run(self, tmp=None, task_vars=None):
    if task_vars is None:
        task_vars = dict()
    super(ActionModule, self).run(tmp, task_vars)

    # Get the "installed_pkgs" variable if it exists, otherwise create an empty list
    mgd_pkgs = task_vars.get('managed_pkgs', [])

    # Get the arguments passed to the action plugin
    new_pkgs = self._task.args.get('pkgs', [])
    if isinstance(new_pkgs,str):
      new_pkgs = new_pkgs.split()

    # Add the new packages to the installed_pkgs list
    for p in new_pkgs:
      if not p in mgd_pkgs: mgd_pkgs.append(p)

    # Update the "installed_pkgs" variable
    task_vars['managed_pkgs'] = mgd_pkgs

    return {
      "changed": False,
      "ansible_facts": {"managed_pkgs": mgd_pkgs},
    }
