#!/bin/bash
USER_HOME=$(eval echo ~${SUDO_USER})
pwd=$(pwd)
argv1=$1

#export OS_USERNAME = admin
chmod +x $USER_HOME/devstack/openrc
. $USER_HOME/devstack/openrc admin admin
echo "===============source after==========="

if [ ! -f "${USER_HOME}/.ssh/${argv1}.pub" ]
then
    echo "Not exist ${argv1}.pub, create ${argv1}.pub"
    test -f ${USER_HOME}/.ssh/${argv1}.pub || ssh-keygen -t rsa -N "" -f ${USER_HOME}/.ssh/${argv1}
    dig www.openstack.org @8.8.8.8 +short
    nova keypair-add --pub-key ${USER_HOME}/.ssh/${argv1}.pub "${argv1}_key"
fi

if [ ! -f "${pwd}/coreos_production_openstack_image.img.bz2" ]
then
    echo "Not Exist CoreOS Image Compressed file, download"
    wget http://beta.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2 $pwd
    bunzip2 $pwd/coreos_production_openstack_image.img.bz2
fi

if ! glance image-list | grep CoreOS > /dev/null
then
glance image-create --name CoreOS  \
                    --visibility public \
                    --disk-format=qcow2 \
                    --container-format=bare \
                    --os-distro=coreos \
                    --file=coreos_production_openstack_image.img
fi

if ! magnum cluster-template-list | grep k8s-cluster-template-coreos > /dev/null
then
magnum cluster-template-create --name k8s-cluster-template-coreos \
                       --image-id CoreOS \
                       --keypair-id "${argv1}_key" \
                       --external-network-id public \
                       --dns-nameserver 8.8.8.8 \
                       --flavor-id m1.small \
                       --network-driver flannel \
                       --coe kubernetes
fi
