#!/bin/bash

VIRTUALBOX_VERSION=5.0.20
LOCALE=ru_RU.UTF-8

locale-gen ${LOCALE}
export LC_ALL=${LOCALE}

apt install -y postgresql libpq-dev python3-dev python3-venv gcc make

pyvenv /home/ubuntu/venv
chown ubuntu:ubuntu /home/ubuntu/venv -R

pg_createcluster --locale ru_RU.UTF-8 --start 9.5 ensemplix
pg_dropcluster --stop 9.5  main

wget -c -t 0 http://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso

mkdir vbga
mount -o ro,loop VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso vbga
sh vbga/VBoxLinuxAdditions.run --nox11
umount vbga
rm -rf vbga VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso
