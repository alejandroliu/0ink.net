---
title: OpenSSH CA
date: "2024-02-06"
author: alex
---
I find this a neat trick: https://github.com/cloudtools/ssh-cert-authority

An implementation in Python as a AWS Lambda: https://github.com/Netflix/bless


# Using OpenSSH Certificates


This section describes using OpenSSH certificates manually, without the
ssh-cert-authority tool.

To begin using OpenSSH certificates you first must generate an ssh key
that will be kept secret and used as the certificate authority in your
environment. This can be done with a command like:

    ssh-keygen -f my_ssh_cert_authority

That command outputs two files:

    my_ssh_cert_authority: The encrypted private key for your new authority
    my_ssh_cert_authority.pub: The public key for your new authority.

Be sure you choose a passphrase when prompted so that the secret is
stored encrypted. Other options to ``ssh-keygen`` are permitted including
both key type and key parameters. For example, you might choose to use
ECDSA keys instead of RSA.

Grab the fingerprint of your new CA:

    $ ssh-keygen -l -f my_ssh_cert_authority
    2048 2b:a1:16:84:79:0a:2e:38:84:6f:32:96:ab:d4:af:5d my_ssh_cert_authority.pub (RSA)

Now that you have a certificate authority you'll need to tell the hosts
in your environment to trust this authority. This is done very similar
to user SSH keys by setting up the `authorized_keys` on your hosts (the
expectation is that you're setting this up at launch time via cloudinit
or perhaps baking the change into an OS image or other form of snapshot).

You have a choice of putting this `authorized_keys` file into
`$HOME/.ssh/authorized_keys` or the change can be made system wide. For
system wide configuration see `sshd_config(5)` and the
`TrustedUserCAKeys` option.

If you are modifying the user's `authorized_keys` file simply add a new
line to `authorized_keys` of the form:

    cert-authority <paste the single line from my_ssh_cert_authority.pub>

A valid line might look like this for an RSA key:

    cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAYQC6Shl5kUuTGqkSc8D2vP2kls2GoB/eGlgIb0BnM/zsIsbw5cWsPournZN2IwnwMhCFLT/56CzT9ZzVfn26hxn86KMpg76NcfP5Gnd66dsXHhiMXnBeS9r6KPQeqzVInwE=

At this point your host has been configured to accept a certificate
signed by your authority's private key. Let's generate a certificate for
ourselves that permits us to login as the user ubuntu and that is valid
for the next hour (This assumes that our personal public SSH key is
stored at ``~/.ssh/id_rsa.pub)`` :

    ssh-keygen -V +1h -s my_ssh_cert_authority -I bvanzant -n ubuntu ~/.ssh/id_rsa.pub

The output of that command is the file ``~/.ssh/id_rsa-cert.pub``. If you
open it it's just a base64 encoded blob. However, we can ask ``ssh-keygen``
to show us the contents:

    $ ssh-keygen -L -f ~/.ssh/id_rsa-cert.pub
    /tmp/test_main_ssh-cert.pub:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT f6:e3:42:5e:72:85:ce:26:e8:45:1f:79:2d:dc:0d:52
        Signing CA: RSA 4c:c6:1e:31:ed:7b:7c:33:ff:7d:51:9e:59:da:68:f5
        Key ID: "bvz-test"
        Serial: 0
        Valid: from 2015-04-13T06:48:00 to 2015-04-13T07:49:13
        Principals:
                ubuntu
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc

Let's use the certificate now::

    # Add the key into our ssh-agent (this will find and add the certificate as well)
    ssh-add ~/.ssh/id_rsa
    # And SSH to a host
    ssh ubuntu@<the host where you modified authorized_keys>

If the steps above were followed carefully you're now SSHed to the
remote host. Fancy?

At this point if you look in `/var/log/auth.log` (Ubuntu) (`/var/log/secure`
on Red Hat based systems) you'll see that the user ubuntu logged in to this
machine. This isn't very useful data. If you change the sshd_config on your 
servers to include `LogLevel VERBOSE` you'll see that the certificate key id
is also logged when a user logs in via certificate. This allows you to map
that user `bvanzant` logged into the host using username ubuntu. This will
make your auditors happy.


