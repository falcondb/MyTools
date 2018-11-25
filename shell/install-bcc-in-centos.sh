BUILDPATH=/tmp

update-toolings

update-bison

#upgrade-kernel-versions

get-kernel-header

install-ply

install-llvm

install-bcc

update-toolings {
  yum install -y epel-release
  yum update -y
  yum groupinstall -y "Development tools"
  yum install -y elfutils-libelf-devel iperf cmake3

}


### bison 3
update-bison {
  pushd .

  cd $BUILDPATH
  mkdir build
  cd build
  curl -OL https://ftp.gnu.org/gnu/bison/bison-3.0.tar.xz
  tar -xf bison-3.0.tar.xz
  cd bison-3.0
  ./configure
  make
  make install
  yum remove -y bison

  popd
}

upgrade-kernel-versions {
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  curl -LO https://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
  yum localinstall -y elrepo-release-7.0-2.el7.elrepo.noarch.rpm
  yum --enablerepo=elrepo-kernel install -y kernel-ml kernel-ml-devel
}

get-kernel-header {
  yumdownloader --enablerepo=elrepo-kernel kernel-ml-headers
  rpm2cpio kernel-ml-headers*.rpm | cpio -idmv
}


install-ply {
  pushd .
  cd $BUILDPATH
  git clone https://github.com/iovisor/ply.git
  cd ply
  ./autogen.sh
   export CFLAGS=-I$BUILDPATH/usr/include
  ./configure
  make
  make install

  popd
}

install-llvm {
  pushd .
  cd $BUILDPATH

  curl -LO http://releases.llvm.org/3.9.1/cfe-3.9.1.src.tar.xz
  curl -LO http://releases.llvm.org/3.9.1/llvm-3.9.1.src.tar.xz
  tar -xf cfe-3.9.1.src.tar.xz
  tar -xf llvm-3.9.1.src.tar.xz
  mkdir clang-build
  mkdir llvm-build

  cd llvm-build
  cmake3 -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="BPF;X86" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ../llvm-3.9.1.src
  make
  sudo make install

  cd ../clang-build
  cmake3 -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="BPF;X86" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ../cfe-3.9.1.src
  make
  make install

  popd
}

install-bcc {
  pushd .
  cd $BUILDPATH

  git clone https://github.com/iovisor/bcc.git
  mkdir bcc-build
  cd bcc-build
  cmake3 -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr ../bcc
  make
  make install

  popd
}
