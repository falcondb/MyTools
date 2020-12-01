function configure_envs {

  if [ $(grep -i centos /etc/os-release | wc -l) -ne 0  ]; then
    OSDIST=centos
    which yum > /dev/null && INSTALLER=yum
    which dnf > /dev/null && INSTALLER=dnf
  elif [ $(grep -i suse /etc/os-release | wc -l) -ne 0  ]; then
    OSDIST=suse
    which zypper > /dev/null && INSTALLER=zypper
  else
    echo No package installer found!
    return 1
  fi

  if [ "$EUID" -ne "0" ]; then
      SUDO="sudo "
  fi
}
