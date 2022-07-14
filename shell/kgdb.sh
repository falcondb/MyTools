function kgdb-configuration {

  # add kgdbwait kgdboc=ttyS0,115200 at the linux in /boot/grub/grub.cfg
  # reboot
  # scp the vmlinux (better with dgb info) to host
  # gdb vmlinux
    ## target remote /dev/ttyS0
}

# https://www.kernel.org/doc/htmldocs/kgdb/kgdbKernelArgs.html
# https://01.org/linuxgraphics/gfx-docs/drm/dev-tools/kgdb.html
# https://www.youtube.com/watch?v=67cxIXLCfUk

# echo ttyS0 > /sys/module/kgdboc/parameters/kgdboc

#GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200n8"
#GRUB_TERMINAL=serial


# Add console=ttyS0,9600n8 to linux command line
# to dump boot message to the serial port

#https://fadeevab.com/how-to-setup-qemu-output-to-console-and-automate-using-shell-script/
