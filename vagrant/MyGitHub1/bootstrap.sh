set -x -e

#yum update 

### GNU autobuild ####
yum install -y gcc
yum install -y autoconf
yum install -y automake
yum install -y libtool

### Install git flow on centos ###
yum install -y git
curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
chmod +x gitflow-installer.sh
sudo ./gitflow-installer.sh

### Editors ###
yum install -y gedit

### GDB ###
yum install -y gdb

### TALLOC ###
yum install -y libtalloc-devel
