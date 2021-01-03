TOOLCOMSH=$(dirname $0)/common-env-setup.sh

[[ -z $OSDIST ] || [ -z $INSTALLER ] || [ -z $SUDO ]] && [[ -f $TOOLCOMSH ]] && . $TOOLCOMSH && echo "Loaded the tool script, $TOOLCOMSH"
install qemu qemu-utils qemu-kvm virt-manager libvirt-daemon-system libvirt-clients bridge-utils -y
