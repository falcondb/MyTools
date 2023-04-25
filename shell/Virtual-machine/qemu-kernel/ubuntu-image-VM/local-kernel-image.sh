function run-kernel-chroot {
# files could be added into chroot, see the 'create-image.sh'
# or chroot $RELEASE /bin/bash -c "apt-get update; apt-get install -y XXXX"
# however the network and ssh is still not working
qemu-system-x86_64 \
-kernel /home/falcon/work/github.com/linux/arch/x86/boot/bzImage \
-append "console=ttyS0 root=/dev/sda debug earlyprintk=serial slub_debug=QUZ" \
-hda ./bullseye.img \
-net nic,model=virtio \
-net user,hostfwd=tcp::10021-:22 -net nic \
-enable-kvm \
-nographic \
-m 4G \
-cpu host \
2>&1

}



function run-kernel-buildroot {
# Tested and working, but no sshd and other nettools
qemu-system-x86_64 \
  -kernel /home/falcon/work/github.com/linux/arch/x86/boot/bzImage \
  -nographic \
  -hda /home/falcon/work/github.com/buildroot/output/images/rootfs.ext2 \
    -append "root=/dev/sda rw console=ttyS0"  \
  -m 4G \
  -enable-kvm \
  -cpu host \
  -smp $(nproc) \
  -net nic,model=virtio \
  -net user,hostfwd=tcp::10022-:22

}

#-drive format=raw,file=/home/falcon/work/github.com/buildroot/output/images/rootfs.ext2,if=virtio \
