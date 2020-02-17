FROM archlinux:latest
ENV USER_NAME="jazzman" \
    NOCONFIRM="--noconfirm --needed"

ARG XFER_COMMAND_OLD="#XferCommand = \/usr\/bin\/curl -L -C - -f -o %o %u"
ARG XFER_COMMAND_NEW="XferCommand = \/usr\/bin\/aria2c --allow-overwrite=true -c --file-allocation=none --log-level=error -m2 --max-connection-per-server=2 --max-file-not-found=5 --min-split-size=5M --no-conf --remote-time=true --summary-interval=60 -t5 --summary-interval=0 --dir=\/ --out %o %u"
ARG PACMAN_CONF="/etc/pacman.conf"

ADD sed.sh /
RUN pacman -Syu aria2 reflector sudo $NOCONFIRM \
    && chmod +x sed.sh \
    && ./sed.sh "$XFER_COMMAND_OLD" "$XFER_COMMAND_NEW" $PACMAN_CONF \
    && ./sed.sh "#Color" "Color" $PACMAN_CONF \
    && reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist \
    && pacman -S $NOCONFIRM \
        binutils fakeroot base-devel \
        atool bzip2 cpio gzip lha xz lzop p7zip tar unace unrar zip unzip \
        rsync wget git openssh imagemagick tree man neovim \
    && ./sed.sh "# %wheel ALL=(ALL) NOPASSWD: ALL" "%wheel ALL=(ALL) NOPASSWD: ALL" /etc/sudoers \
    && useradd -m -g users -G wheel $USER_NAME

USER $USER_NAME
RUN cd $HOME \
    && git clone https://aur.archlinux.org/yay-bin.git \
    && cd yay-bin && makepkg -si --noprogressbar $NOCONFIRM && cd .. && rm -dR yay-bin/ \
    && yay -Syu makepkg-optimize --removemake $NOCONFIRM