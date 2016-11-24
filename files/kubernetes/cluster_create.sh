#!/bin/bash
#cluster_create.sh
USER_HOME=$(eval echo ~${SUDO_USER})

. $USER_HOME/devstack/openrc admin admin

argc=$#
argv1=$1

if ! magnum cluster-list | grep $argv1 > /dev/null
then
magnum cluster-create --name $argv1 \
	--cluster-template k8s-cluster-template-coreos \
	--node-count 1
fi

if ! kubectl > /dev/null 2>&1
then
wget https://github.com/kubernetes/kubernetes/releases/download/v1.4.6/kubernetes.tar.gz
tar -xvzf kubernetes.tar.gz
sudo cp -a kubernetes/platforms/linux/amd64/kubectl /usr/bin/kubectl
fi
