#!/bin/bash
# parameter1: cluster-name, parameter2: kubernetes_url
USER_HOME=$(eval echo ~${SUDO_USER})
echo $USER_HOME

. $USER_HOME/devstack/openrc admin admin


# Set kubectl to use the correct cert
argv1=$1
KUBERNETES_URL=$(magnum cluster-show $argv1 | awk '/ api_address /{print $4}')
echo $KUBERNETES_URL

clientConf="${USER_HOME}/.ssh/client.conf"
clientKey="${USER_HOME}/.ssh/client.key"
clientCsr="${USER_HOME}/.ssh/client.csr"
clientCrt="${USER_HOME}/.ssh/client.crt"
caCrt="${USER_HOME}/.ssh/ca.crt"

if [ ! -f $clientKey ]
then
echo "Not Exsist ClientKey, create clientKey"
openssl genrsa -out client.key 4096
mv ./client.key $clientKey
fi

if [ ! -f $clientConf ]
then
echo "Not Exist clientConf, create clientKey"
cat > client.conf << END
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no
[req_distinguished_name]
CN = Your Name
[req_ext]
extendedKeyUsage = clientAuth
END
mv ./client.conf $clientConf
fi

if [ ! -f $clientCsr ]
then
openssl req -new -days 365 -config $clientConf -key $clientKey -out $clientCsr
fi

magnum ca-sign --cluster $argv1 --csr $clientCsr > $clientCrt
magnum ca-show --cluster $argv1 > $caCrt

if [ "${KUBERNETES_URL}" = "-" ]
then
   echo "Now, cluster is creating... please re run this script after cluster created"
   exit 1
else
    # Set kubectl to use the correct certs
    kubectl config set-cluster $argv1 --server=$KUBERNETES_URL --certificate-authority=$caCrt
    kubectl config set-credentials client --certificate-authority=$caCrt --client-key=$clientKey --client-certificate=$clientCrt
    kubectl config set-context $argv1 --cluster=$argv1 --user=client
    kubectl config use-context $argv1
    #Test the cert and connection works
    kubectl version
fi


#Comment!!
if false
then
IP_ADDRESS=$(echo $KUBERNETES_URL | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
#IF  there is no exist kube_api in host file, then insert host line
#q option => quiet
if ! grep -q "${IP_ADDRESS}    kube-apiserver" "/etc/hosts"
then
    #필요없는 kube-apiserver 지워버림
    sed "/kube-apiserver/d" /etc/hosts
    sudo -- sh -c "echo ${IP_ADDRESS}   kube-apiserver >> /etc/hosts"
fi
#6443 port 만들어야함 ~/.kube/config.yaml 에서 server: https://kube-apiserver:6443
sed -iq 's/\(.*server:.*\)/    server: https:\/\/kube-apiserver:6443/g' $USER_HOME/.kube/config
fi
