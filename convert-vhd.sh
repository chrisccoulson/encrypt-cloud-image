#!/bin/sh
set -x
set -e
img=$1
[ -n "$img" ]
sudo qemu-nbd -d /dev/nbd5
sudo qemu-nbd -f vpc -c /dev/nbd5 $img
sleep 2
sudo mount /dev/nbd5p1 /mnt
sudo mount /dev/nbd5p15 /mnt/boot/efi
sudo mount -o bind /sys /mnt/sys
sudo mount -o bind /dev /mnt/dev
sudo mount -o bind /dev/pts /mnt/dev/pts
sudo mount -o bind /proc /mnt/proc
sudo mount -o bind /run /mnt/run
sudo chroot /mnt add-apt-repository -y ppa:mhcerri/azure-test
sudo chroot /mnt apt install -y linux-azure-fde
for prog in /usr/sbin/update-grub /usr/sbin/grub-install /usr/lib/grub/grub-multi-install; do
    sudo chroot /mnt dpkg-divert --rename --local --divert $prog.fde --add $prog
    sudo chroot /mnt ln -s /bin/true $prog
done
sudo cp /mnt/usr/lib/linux/kernel.efi* /mnt/boot/efi/EFI/ubuntu/grubx64.efi
sudo umount /mnt/dev/pts /mnt/dev /mnt/sys /mnt/proc /mnt/run /mnt/boot/efi /mnt
sudo qemu-nbd -d /dev/nbd5



