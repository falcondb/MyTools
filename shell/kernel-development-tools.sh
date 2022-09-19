GRUBDEF=/etc/default/grub
IMAGEBUPATH="./images"
function show-grub-boot-index {
## copy from Bytedance team
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

function change-grub-default-version {
  [[ $# -lt 1 ]] && echo "Usage: Fisrt argument: Your default version?" && return 1

  echo "Replacing $GRUBDEF with default version $1"

  $SUDO sh -c "sed -i "s/^GRUB_DEFAULT=.*$/GRUB_DEFAULT=\"$1\"/g" $GRUBDEF" \
  && $SUDO update-grub && $SUDO reboot
}


function kernel-build-deploy {
  [[ -n $LSRC ]] && echo "Set \$LSRC to the path of Linux source code" && return 1

  ./build.sh && \
  install-kernel-packages

  # show-grub-boot-index
  # change-grub-default-version
}

function cleanup-bpftools {
  [[ -n $LSRC ]] && echo "Set \$LSRC to the path of Linux source code" && return 1
  pushd .

  echo "cleaning up $LSRC/tools/bpf/bpftool"
  cd $LSRC/tools/bpf/bpftool
  sudo make clean

  echo "cleaning up $LSRC/tools/lib/bpf/"
  cd $LSRC/tools/lib/bpf/
  sudo make clean

  popd
}


function install-kernel-packages {
sudo dpkg -i $LSRC/../linux-image*.deb  \
             $LSRC/../linux-libc*.deb \
             $LSRC/../linux-headers*.deb
}

function cleanup-backup-package {
  CUFEXTS=("gz" "buildinfo" "dsc" \
            "changes")

  for w in "${CUFEXTS[@]}" ; do
    rm -f *.$w
    echo "Removed files like *.$w"
  done

  [[ -z $IMAGEBUPATH ]] && echo "ENV IMAGEBUPATH is not empth" && return 1
  [[ -n $1 ]] && mv linux*$1*.deb $IMAGEBUPATH
}


function cleanup-kernel-packages {
  sudo apt-get --purge remove -y \
    $(dpkg --list | egrep -i \
    'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i")
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
