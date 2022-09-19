PROJPATH=/data00/VMs-ym/playground
QIMAGE=$PROJPATH/current.qcow2
QIMGSIZE=50G
IMGDEV=nbd0
IMGMOUNT=/data00/VMs-ym/playground/$IMGDEV


qemu-img create -f qcow2 $QIMAGE $QIMGSIZE

#modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/$IMGDEV $QIMAGE

sudo mkfs.ext4 /dev/$IMGDEV

mkdir $IMGMOUNT
sudo mount /dev/$IMGDEV $IMGMOUNT
#qemu-nbd --disconnect /dev/nbd0
#umount  $IMGMOUNT


wget http://cloud-images-archive.ubuntu.com/releases/focal/release-20200423/ubuntu-20.04-server-cloudimg-amd64.img

#apt-get install libguestfs-tools
virt-customize -a ubuntu-20.04-server-cloudimg-amd64.img  --root-password password:QEMUkvm
# virt-customize -a [path] --install XXX

qemu-system-x86_64 -m 512m -nographic -hda /data00/VMs-ym/u20-ym/ubuntu-20.04.3-desktop-amd64.iso -hdb $IMGMOUNT
