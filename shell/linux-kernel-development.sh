if [ -z $OSDIST ] || [ -z $INSTALLER ] || [ -z $SUDO ] ; then
[[ -f $TOOLCOMSH ]] && . $TOOLCOMSH && echo "Loaded the tool script, $TOOLCOMSH"
fi

OSARCH=$(uname -m)
QEMUBIN=qemu-system-$OSARCH

TOOLS=/home/work/github.com
[[ -n $GITROOT ]] && TOOLS=$GITROOT

LSRC=$TOOLS/linux
RTFS=$TOOLS/buildroot

KERNISOFILE=kernel_iso.iso

function install-tools {
  $SUDO $INSTALLER install -y build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache flex bison libelf-dev
}

function clone-linux-source-code {
  git clone https://github.com/torvalds/linux.git
  LSRC=$PWD/linux
}

function build-configuration {
  [[ -z $LSRC ]] && "Linux source code path is not set at LSRC!" && return 1
  cd $LSRC
  [[ -z $OSARCH ]] && OSARCH=$(uname -m)

  #make ARCH=$OSARCH defconfig
  #[[ ! -f .config ]] && "ARCH configuration failed!" && return 2

  #make ARCH=$OSARCH menuconfig

  \cp -v /boot/config-$(uname -r) .config
  make olddefconfig

  #scripts/config --disable SYSTEM_TRUSTED_KEYS
  #scripts/config --disable SYSTEM_REVOCATION_KEYS

  make -j8 | tee kernel-build.log && echo "Kernel image is built successfully!" || return 3

  [[ ! -x ./vmlinux ]] && echo "Kernel executable doesn't exit!" && return 4

  $SUDO make bindeb-pkg
  $SUDO make modules_install
  $SUDO make install headers_install
  $SUDO update-grub

  $SUDO  /usr/sbin/grub-set-default /boot/vmlinuz-$KERNEL_VERSION

  # try gdb ./vmlinux to play with the kernel. Check out the GDB script apropos lx
}

function install-kernel-packages {
  sudo  dpkg -i linux-image-*.deb
  sudo  dpkg -i linux-headers*.deb
  sudo  dpkg -i linux-libc*.deb

  sudo reboot
}

function build-root-fs {
  pushd .
  cd $TOOLS
  git clone https://github.com/buildroot/buildroot.git && cd buildroot && RTFS=$PWD

  # select
  make menuconfig

  make -j8 || (echo "building root fs failed!"; return 5)

  popd
}

# The QEMU options used:
#   -kernel   Uses bzImage as kernel image. The kernel can be either a Linux kernel or in multiboot format.
#   -boot     Specifies boot order drives as a string of drive letters.
#               The x86 PC uses: a, b (floppy 1 and 2), c (first hard disk), d (first CD-ROM), n-p (Etherboot from network adapter 1-4), hard disk boot is the default
#   -m        Sets guest startup RAM size to megs megabytes. Default is 128 MiB. Optionally, a suffix of “M” or “G” can be used.
#   -hda      Uses file as hard disk 0, 1, 2 or 3 image
#   -append   Gives the kernel command line arguments
#   -serial   Redirects the virtual serial port to host character device dev. The default device is vc in graphical mode and stdio in non graphical mode.
#   -display  Selects type of display to use. Type none: Do not display video output.  -nographic disable graphical output so that QEMU is a simple command line application.
#   -enable-kvm Enable KVM full virtualization support.
#   -no-reboot  Exit instead of rebooting.
#   -cpu host Select CPU model  VM processor with all supported host features
#
function run-qemu {
  [[ -z $1 ]] && KIMG=$LSRC/arch/x86/boot/bzImage || KIMG=$1
  [[ -z $2 ]] && RTPATH=$RTFS/output/images/rootfs.ext2 || RTPATH=$2
  $QEMUBIN -kernel $KIMG \
    -boot c -m 2049M -hda $RTPATH \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial stdio -display none -enable-kvm -no-reboot
}



function update-kernel-ISO {

  [[ $# -lt 3 ]] && echo "Usage:  ISOPATH KERNEL_FILE PATH_IN_ISO" && return 1

  local OPATH=/tmp/orig_iso
  local KPATH=/tmp/kernel_iso

  $SUDO mkdir $WPATH $KPATH

  $SUDO mount -o loop $1 $OPATH
  $SUDO cp -r $OPATH $KPATH

  $SUDO umount $OPATH

  cp $2 $3

  $SUDO genisoimage -o $KERNISOFILE $KPATH
  # isoinfo -l -i $KERNISOFILE

  rm -rf $OPATH $WPATH

}



function run-qemu-iso {
  [[ -z $1 ]] && KIMG=$LSRC/arch/x86/boot/bzImage || KIMG=$1
  [[ -z $2 ]] && RTPATH=$RTFS/output/images/rootfs.ext2 || RTPATH=$2
  $QEMUBIN -kernel $KIMG \
    -boot c -m 2049M -boot d -cdrom $RTPATH -hda mydisk.img\
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial stdio -display none -enable-kvm -no-reboot


    #VFS: Unable to mount root fs on unknown-block(8,0) ]---
}

function VM-rollback {
  VMFILEPATH=/data00/VMs-ym/u20-ym
  DOMAIN=u20-kern
  VMXML=u20-ym.xml
  QCOWFILE=u20-ym.qcow2
  BUFILE=new-backup

  [[ -n $1 ]] && BUFILE=$1
  cd $VMFILEPATH

  VMID=$(virsh domid $DOMAIN)
  [[ -n $VMID ]] && virsh destroy $VMID

  sleep 1

  yes | \cp -f  backup-qcow2/$BUFILE.qcow2  $QCOWFILE

  virsh create $VMXML

  sleep 1
  VMID=$(virsh domid $DOMAIN)

}


function VM-backup {
  VMFILEPATH=/data00/VMs-ym/u20-ym
  DOMAIN=u20-kern
  VMXML=u20-ym.xml
  QCOWFILE=u20-ym.qcow2
  BUFILE=new-backup

  [[ -n $1 ]] && BUFILE=$1
  cd $VMFILEPATH

  VMID=$(virsh domid $DOMAIN)
  [[ -n $VMID ]] && virsh destroy $VMID

  sleep 1

  yes | \cp -f  $QCOWFILE  backup-qcow2/$BUFILE.qcow2

  virsh create $VMXML

  sleep 1
  VMID=$(virsh domid $DOMAIN)

}



function get_vm_ip() {
    export VMIP=`virsh -q domifaddr "$VM_ID" | awk '{print $4}' | sed -E 's|/([0-9]+)?$||'`
    echo $VMIP
}

function show-grub-boot-index {
// copy from Bytedance team
  </boot/grub/grub.cfg \
awk '
        BEGIN { menu = 0; entry = 0; };
        $1 == "submenu" { menu += 1; entry = 0;}
        $1 == "menuentry" {
                if (menu) printf("%d>", menu);
                split($0, et, "'\''");
                printf("%d %s\n", entry, et[2]);
                entry += 1;
        }
'

}


function build-bpftool-chain {
  local BTFFILE=/sys/kernel/btf/vmlinux

  pushd .

  echo "building libbpf..."
  cd $LSRC/tools/lib/bpf
  make

  echo "building bpftool..."
  cd $LSRC/tools/bpf/bpftool
  make && which bpftool

  echo "generating vmlinux.h"

  [[ -f $BTFFILE ]] && ./bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h \
    || echo "$BTFFILE doesn't exit, recompile kernel with CONFIG_DEBUG_INFO_BTF=y"

  popd
}


function kernel-build-deploy {
  ./build.sh && sudo dpkg -i $LSRC/../linux-image*.deb $LSRC/../linux-libc*.deb $LSRC/../linux-headers*.deb
}


#virsh snapshot-create-as --domain u20-ym --name "before-kernel" --description "before playing with the kernel"
#Operation not supported: internal snapshots of a VM with pflash based firmware are not supported
