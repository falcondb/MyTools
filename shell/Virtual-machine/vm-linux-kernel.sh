PROJPATH=/data00/VMs-ym/playground
QIMAGE=$PROJPATH/current.qcow2
QIMGSIZE=50G
IMGDEV=nbd0
qemu-img create -f qcow2 $QIMAGE $QIMGSIZE

#modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/$IMGDEV $QIMAGE
