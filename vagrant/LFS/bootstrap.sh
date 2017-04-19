set -x -e

yum update 

## My preferred tools ##

### GNU autobuild ####
yum install -y gcc
yum install -y gcc-c++
yum install -y autoconf
yum install -y automake

### Install git flow on centos ###
yum install -y git
curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
chmod +x gitflow-installer.sh
sudo ./gitflow-installer.sh

### Editors ###
yum install -y gedit
yum install -y xorg-x11-xauth xterm

## LFS required tools ##
yum install -y binutils bison coreutils

wget http://ftp.gnu.org/gnu/bison/bison-2.5.1.tar.gz && \
tar xvf bison-2.5.1.tar.gz && \
cd bison-2.5.1 && \
./configure --prefix=/usr/local/bison && \
make && sudo make install && cd ..

yum install -y findutils diffutils gawk patch perl texinfo xz byacc


