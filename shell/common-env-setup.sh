#!/bin/bash

function configure_envs {

  if [ $(grep -i centos /etc/os-release | wc -l) -ne 0  ]; then
    OS=centos
    which yum > /dev/null && INS=yum
    which dnf > /dev/null && INS=dnf
  elif [ $(grep -i suse /etc/os-release | wc -l) -ne 0  ]; then
    OS=suse
    which zypper > /dev/null && INS=zypper
  elif [ $(grep -i debian /etc/os-release | wc -l) -ne 0  ]; then
    OS=debian
    which apt > /dev/null && INS=apt
  elif [ $(grep -i Ubuntu /etc/lsb-release | wc -l) -ne 0 ]; then
    OS=ubuntu
    which apt > /dev/null && INS=apt
  else
    echo No package installer found!
    return 1
  fi

  export OSDIST=$OS
  export INSTALLER=$INS
  echo "OS Distribution : $OSDIST"
  echo "Installer       : $INSTALLER"

  if [ "$EUID" -ne "0" ]; then
      export SUDO="sudo "
  fi
}

configure_envs
