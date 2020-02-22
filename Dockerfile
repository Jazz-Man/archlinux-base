FROM archlinux:latest
MAINTAINER Sokolyk Vasyl <vsokolyk@gmail.com>
ENV USER_NAME="jazzman" \
    NOCONFIRM="--noconfirm --needed --noprogressbar"

COPY rootfs/* /
RUN chmod +x *.sh && ./add-aur.sh \
    && yes | LC_ALL=en_US.UTF-8 pacman -Scc $NOCONFIRM \
    && rm -rf /usr/share/man/* && rm -rf /tmp/* && rm -rf /var/tmp/*