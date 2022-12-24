---
title: Munin-tweaks
---
Small recipes to tweak munin configurations.

# Overriding critical and warning levels

In the node configuration enter:

```
plugin.field_name.critical value
plugin.field_name.warning value
```

The plugin name can be found by clicking in the graph with the value
you want to override.  The last component of the url (without the `.html`)
is the plugin name.

The field name is in this view under the column `Internal name`.

Example:

```
[xenhosts;cn4.localnet]
  address cn4.localnet
  use_node_name no

  vgs.pool0_.warning 99.00
  vgs.pool0_.critical 99.50
```

# Reference documentation

- [config field directives](http://guide.munin-monitoring.org/en/latest/reference/munin.conf.html#field-directives)

