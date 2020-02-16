FROM archlinux:latest
ENV USER_NAME "docker"
ARG XFER_COMMAND_OLD="#XferCommand = \/usr\/bin\/curl -L -C - -f -o %o %u"
ARG XFER_COMMAND_NEW="XferCommand = \/usr\/bin\/aria2c --allow-overwrite=true -c --file-allocation=none --log-level=error -m2 --max-connection-per-server=2 --max-file-not-found=5 --min-split-size=5M --no-conf --remote-time=true --summary-interval=60 -t5 --summary-interval=0 --dir=\/ --out %o %u"
ARG PACMAN_CONF="/etc/pacman.conf"
ARG PHP_INI_FILE="/etc/php/php.ini"
ARG NOCONFIRM="--noconfirm --needed"
ADD . /
RUN pacman -Syu aria2 reflector $NOCONFIRM \
    && chmod +x sed.sh \
    && ./sed.sh "$XFER_COMMAND_OLD" "$XFER_COMMAND_NEW" $PACMAN_CONF \
    && ./sed.sh "#Color" "Color" $PACMAN_CONF \
    && reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -S binutils fakeroot sudo base-devel git $NOCONFIRM \
    && useradd $USER_NAME \
    && mkdir /home/$USER_NAME \
    && chown -R $USER_NAME:$USER_NAME /home/$USER_NAME \
    && echo "$USER_NAME ALL=NOPASSWD: ALL" >> /etc/sudoers
USER $USER_NAME
RUN cd /home/$USER_NAME \
    && git clone https://aur.archlinux.org/yay-bin.git \
    && cd yay-bin && makepkg -si $NOCONFIRM && cd .. && rm -dR yay-bin/ \
    && yay -Syu makepkg-optimize $NOCONFIRM