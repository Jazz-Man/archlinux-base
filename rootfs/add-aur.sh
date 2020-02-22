#!/usr/bin/env bash
set -o pipefail -e
pacman -Syyu git sudo wget $NOCONFIRM
useradd -m $USER_NAME
echo "${USER_NAME}:" | chpasswd -e
pkgs=$(pacman -S base-devel --print-format '%n ');pkgs=${pkgs//systemd/};pkgs=${pkgs//$'\n'/}
pacman -S $NOCONFIRM $pkgs
echo "$USER_NAME ALL = NOPASSWD: ALL" >> /etc/sudoers
./sed.sh '#MAKEFLAGS="-j2"' 'MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf

su $USER_NAME -c 'cd; git clone https://aur.archlinux.org/yay-bin.git'
su $USER_NAME -c 'cd; cd yay-bin; makepkg'
pushd /home/$USER_NAME/yay-bin/
pacman -U *.pkg.tar.xz $NOCONFIRM
popd
rm -rf /home/$USER_NAME/yay-bin

# do a yay system update
su $USER_NAME -c "yay -Syyu $NOCONFIRM"

#echo "Packages from the AUR can now be installed like this:"
#echo "su $USER_NAME -c 'yay -S --needed --noprogressbar --needed --noconfirm PACKAGE'"
