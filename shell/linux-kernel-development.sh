if [ -z $OSDIST ] || [ -z $INSTALLER ] || [ -z $SUDO ] ; then
[[ -f $TOOLCOMSH ]] && . $TOOLCOMSH && echo "Loaded the tool script, $TOOLCOMSH"
fi

OSARCH=$(uname -m)
QEMUBIN=qemu-system-$OSARCH

TOOLS=/home/work/github.com
LSRC=$TOOLS/linux
RTFS=$TOOLS/buildroot

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

  make ARCH=$OSARCH $OSARCH_defconfig
  [[ ! -f .config ]] && "ARCH configuration failed!" && return 2

  make ARCH=$OSARCH menuconfig

  make -j8 | tee kernel-build.log && echo "Kernel image is built successfully!" || return 3

  [[ ! -x ./vmlinux ]] && echo "Kernel executable doesn't exit!" && return 4

  # try gdb ./vmlinux to play with the kernel. Check out the GDB script apropos lx
}

function build-root-fs {
  pushd .
  cd $TOOLS
  git clone https://github.com/buildroot/buildroot.git && cd buildroot && RTFS=$PWD

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
