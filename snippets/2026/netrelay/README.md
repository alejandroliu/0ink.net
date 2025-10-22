# NetRelay

**netrelay** forwards traffic between _qemu_ VMs, other
**netrelay** instances, or Linux bridge interfaces.

`netrelay` is a relay utility for QEMU VM traffic. It
forwards Ethernet frames between endpoints using TCP, UDP
or Linux bridge interfaces. It can run in two modes:

- **Point-to-point**: Like a virtual crossover cable
- **Server mode**: A dumb hub that distributes frames to all connected clients

It’s compatible with QEMU’s `-net socket` mode and uses QEMU-style
framing over TCP for interoperability.
