rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

yum --enablerepo=elrepo-kernel install kernel-ml

awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

grub2-set-default 0

grub2-mkconfig -o /boot/grub2/grub.cfg

reboot


## Clean up old versions
#yum install yum-utils
#package-cleanup --oldkernels
