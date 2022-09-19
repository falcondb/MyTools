
function build-bpftool-chain {
  local BTFFILE=/sys/kernel/btf/vmlinux

  [[ -z $LSRC ]] && echo "Set \$LSRC to the path of Linux source code" && return 1

  pushd .

  echo "building libbpf..."
  cd $LSRC/tools/lib/bpf
  make

  echo "building bpftool..."
  cd $LSRC/tools/bpf/bpftool
  sudo make install && which bpftool

  echo "generating vmlinux.h"

  [[ -f $BTFFILE ]] && $SUDO sh -c  \
    "./bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h " \
    || echo "$BTFFILE doesn't exit, recompile kernel with CONFIG_DEBUG_INFO_BTF=y"

  popd
}



function make-bpf-tools {
  pushd .
  cd $LSRC/tools/bpf/bpftool/bpftool
  make install
  popd
}

function read-bpf-output {
   cat /sys/kernel/debug/tracing/trace_pipe
}


function clear-bpf-output {
  echo > /sys/kernel/debug/tracing/trace
}


function use-bpf-auto-completion {
  local BASHAUTOCOMP=/usr/share/bash-completion/bash_completion
  local BPFTOOLCOMP=$LSRC/tools/bpf/bpftool/bash-completion/bpftool

  if [[ ! -e $BPFTOOLCOMP ]] ; then
    echo "bash-completion for bpftool is not found at $BPFTOOLCOMP"
    echo "get a copy of it from a latest Linux source code"
    return 1
  fi

  if [[ ! -f $BASHAUTOCOMP ]] ; then
    [[ -z $INSTALLER ]] && INSTALLER=apt-get
    $SUDO $INSTALLER install -y bash-completion
  fi

  . $BASHAUTOCOMP
  . $BPFTOOLCOMP

    ## BASHPROFILE=~/.bashrc
    ## grep $BASHAUTOCOMP $BASHPROFILE || echo ". " $BASHAUTOCOMP  >> $BASHPROFILE
    ## grep $BPFTOOLCOMP  $BASHPROFILE || echo ". " $BPFTOOLCOMP  >> $BASHPROFILE
}

function enable-bpf-stats {
  sysctl -w kernel.bpf_stats_enabled=1
  ## echo 1 > /proc/sys/kernel/bpf_stats_enabled
}
