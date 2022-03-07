TOOLCOMSH=$(dirname $0)/common-env-setup.sh
QEMUGROUP=libvirt
LVDS=libvirtd.service

if [ -z $OSDIST ] || [ -z $INSTALLER ] || [ -z $SUDO ] ; then
[[ -f $TOOLCOMSH ]] && . $TOOLCOMSH && echo "Loaded the tool script, $TOOLCOMSH"
fi

$SUDO $INSTALLER install qemu qemu-utils qemu-kvm virt-manager libvirt-daemon-system libvirt-clients bridge-utils -y


function addUser2QM {
  local USER=$(whoami)
  [[ $($SUDO getent group | grep $QEMUGROUP) ]] || $SUDO groupadd --system $QEMUGROUP

  [[ $(id $USER | grep $QEMUGROUP) ]] || $SUDO usermod -a -G  $QEMUGROUP  $USER

  id $USER | grep $QEMUGROUP
}

function restartLibvertd {

  [[ $SUDO systemctl | egrep "$LVDS.*running" ]] || $SUDO systemctl restart $LVDS
  $SUDO systemctl status $LVDS
}

## make sure the Virtualization Technology is enabled in the BIOS configuration

sudo modprobe kvm-intel

cp -v /etc/libvirt/libvirt.conf ~/.config/libvirtd/libvirt.conf



function compile-qemu {
  $SUDO apt install -y libglib2.0-dev libffi-dev ninja-build libpixman-1-dev

}
