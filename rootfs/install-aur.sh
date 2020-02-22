#!/usr/bin/env bash

PACKAGE=$1

su $USER_NAME -c "yay -S $NOCONFIRM --removemake $PACKAGE"