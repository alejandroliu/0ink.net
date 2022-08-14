#!/bin/sh
#
if [ $(id -u) -ne 0 ] ; then
  echo "Using sudo..." 1>&2
  exec sudo /bin/sh "$0" "$@"
fi

vgroup=libvirt

xbps-install -y -S libvirt dbus qemu

echo -n "Enabling services: "
for sv in dbus libvirtd virtlockd virtlogd
do
  [ -e /var/service/$sv ] && continue
  echo -n " $sv"
  ln -s /etc/sv/$sv /var/service
done
echo ' ... done'


if [ -d /sys/module/kvm_intel ] ; then
  kvm_variant=kvm_intel
elif [ -d /sys/module/kvm_amd ] ; then
  kvm_variant=kvm_amd
else
  echo "Unsopported KVM variant" 1>&2
  exit 2
fi

case "$(cat /sys/module/$kvm_variant/parameters/nested)" in
1|Y)
  echo "Nested virtualization is enabled." 1>&2
  ;;
*)
  echo "Nested virtualization is disabled." 1>&2
  cat 1>&2 <<-EOF
	  To enable add to /etc/modprobe.d/kvm.conf:
	    options $kvm_variant nested=1

	  Then:
	    sudo modprobe -r $kvm_variant
	    sudo modprobe $kvm_variant

	  and try again.
	EOF
  exit 3
esac

if [ -n "${DISPLAY:-}" ] ; then
  echo "Using $DISPLAY"

  xbps-install -y virt-manager virt-manager-tools

fi

if [ -n "${SUDO_USER:-}" ] ; then
  echo "SUDO_USER: $SUDO_USER"

  if ! (id -nG $SUDO_USER | grep -q '\b'"$vgroup"'\b') ; then
    echo "Adding $SUDO_USER to $vgroup" 1>&2
    usermod -a -G "$vgroup" "$SUDO_USER"
    echo "You must logout and login again for this to work"
  fi

fi

# Note the documentation says that polkitd (from polkit package) needs
# to be enable in /var/service, but that doesn't seem to be the case
# as it starts automatically.

