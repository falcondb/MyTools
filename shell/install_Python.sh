function install_python {
  PVER=3.9.1
  [[ -n $1 ]] && PVER=$1

  set -e

  pushd .
  cd /tmp

  wget https://www.python.org/ftp/python/$PVER/Python-${PVER}.tgz
  tar -xzf Python-$PVER.tgz

  cd Python-$PVER
  ./configure --enable-optimizations && make -j 2 && sudo make altinstall

  which python-$PVER

  rm -rf Python-${PVER}.tgz Python-${PVER}

  popd
  set +e
}
