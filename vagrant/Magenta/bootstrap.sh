set -x -e

#yum update

### GNU autobuild ####
yum install -y gcc
yum install -y autoconf
yum install -y automake

### Magenta Requred ###
yum install -y texinfo libglib2.0-dev libtool libsdl-dev build-essential

### Install git flow on centos ###
yum install -y git
curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
chmod +x gitflow-installer.sh
sudo ./gitflow-installer.sh

echo -e  "export PS1='\[\033[1;36m\]\u:\w$\[\033[0m\] '; " >> /home/vagrant/.bashrc
