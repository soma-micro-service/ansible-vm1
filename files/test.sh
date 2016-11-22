#!/bin/bash
USER_HOME=$(eval echo ~${SUDO_USER})

if [ ! -f "${USER_HOME}/coreos_production_openstack_image.img.bz2" ]
then
    echo "${USER_HOME}/coreos_production_openstack_image.img.bz2"
    echo "Not Exist CoreOS Image Compressed file, download"
fi
