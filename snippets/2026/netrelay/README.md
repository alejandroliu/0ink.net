# NetRelay

Copyright 2025 Alejandro Liu

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the following
conditions are met:
 *
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following
   disclaimer in the documentation and/or other materials provided
   with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
“AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

**netrelay** forwards traffic between _qemu_ VMs, other
**netrelay** instances, or Linux bridge interfaces.

`netrelay` is a relay utility for QEMU VM traffic. It
forwards Ethernet frames between endpoints using TCP, UDP
or Linux bridge interfaces. It can run in two modes:

- **Point-to-point**: Like a virtual crossover cable
- **Server mode**: A dumb hub that distributes frames to all connected clients

It’s compatible with QEMU’s `-net socket` mode and uses QEMU-style
framing over TCP for interoperability.
