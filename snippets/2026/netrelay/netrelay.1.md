# netrelay.1
:version: 1.0

## NAME

**netrelay** -- Relay _qemu_ VM traffic

## SYNOPSIS

- **netrelay** [-v] [_src_] [_dest_]
  - point-to-point connection
- **netrelay** [-v] **-l** _port_ [_target_ ...]
  - server mode

## DESCRIPTION

**netrelay** forwards traffic between _qemu_ VMs, other
**netrelay** instances, or Linux bridge interfaces.

It makes it possible for a _qemu_ VM to connect to communicate
across hosts or to connect to a bridge interface *without* the
need of admin priviledges.

It can operate as a point to point connection (i.e. like a
straight cable, or as dumb hub-like server accepting multiple
connections and distributing traffic across all connected
clients.

## OPTIONS

- **-l** _port_ : Enable server mode.
- _src_ | _dest_ | _target_ : Specify an end-point of
  point-to-point connection or a target to connect the hub/server
  mode on start-up.

## TARGETS

Specifying targets for point-to-point connections or server mode:

- `-` : Use stdio, for testing.
- _listening-port_ : _ip-address_ : _sending-port_ : UDP connection,
  you can omit the _listening-port_ or the _sending-port_, but at
  least one of those needs to be specified.  It will use the same
  value for the missing one.  IP address can be a IPv4 quad-dotted
  numbers, or an IPv6 address enclosed with square brackets ( `[]` ).
- _ip-address_ : _port_ : TCP connection,
  IP address can be a IPv4 quad-dotted numbers, or an IPv6
  address enclosed with square brackets ( `[]` ).  You must
  specify the _port_ number of the listening server.
- _bridge_ : specify a bridge to connect to.

## COMPATIBILITY

**netrelay** will interoperate with _qemu_ VM network interfaces
using `udp` mode, or tcp `server` or `client` modes.

When connecting to a _bridge_ interface, it will do so by
creating a `tap` device and connecting it to the _bridge_.
Received frames from VMs or other clients are sent directly
to the `tap` device.

With _qemu_ using the `udp` mode works well with VMs in the same
host as it uses the loopback device.  However, communicating with
VMs on other hosts this is unreliable due to MTU limits which
may cause too much packet fragmentation.  Using one of `tcp`
modes can overcome this but introduces dependancies on how
VMs need to be brought up.  To make matters more complicated,
_qemu_ only establish TCP tunnels on definition, and will no
try to re-connect later.  Using **netrelay** as a connecting
glue can be used to work around these problems.

## BUGS

**netrelay** only acts as a dumb hub. It does not try to
look into the frames *MAC destination* or *MAC source* address
to implement bridging/switching.  Similarly, network loops
are not considered.

## TODO
- UDP connections, should be possible to do listen::target
  listen and target must be different, IP address would
  default to 127.0.0.1
