if [ -z $OSDIST ] || [ -z $INSTALLER ] || [ -z $SUDO ] ; then
[[ -f $TOOLCOMSH ]] && . $TOOLCOMSH && echo "Loaded the tool script, $TOOLCOMSH"
fi

OSARCH=x86_64
QEMUBIN=qemu-system-x86_64

TOOLS=/home/work/github.com

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

  # try gdb ./vmlinux to play with the kernel
}

function build-root-fs {
  pushd .
  cd $TOOLS
  git clone https://github.com/buildroot/buildroot.git && cd buildroot && RTFS=$PWD

  make menuconfig

  make -j8 || (echo "building root fs failed!"; return 5)

  popd
}

function run-qemu {
  [[ -z $1 ]] && KIMG=$LSRC/arch/x86/boot/bzImage || KIMG=$1
  [[ -z $2 ]] && RTPATH=$LSRC/arch/x86/boot/bzImage || RTPATH=$2
  $QEMUBIN -kernel $KIMG \
    -boot c -m 2049M -hda $RTPATH \
    -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
    -serial stdio -display none
}
