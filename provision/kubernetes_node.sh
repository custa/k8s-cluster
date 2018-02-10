#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"


cp /vagrant/kubernetes/server/bin/{kube-proxy,kubelet} /usr/bin
mkdir -p /etc/kubernetes
\cp ${LOCATION_PATH}/etc/kubernetes/{config,proxy,kubelet} /etc/kubernetes

cp -r ${LOCATION_PATH}/etc/kubernetes /etc
cp ${LOCATION_PATH}/usr/lib/systemd/system/{kube-proxy.service,kubelet.service} /usr/lib/systemd/system/
mkdir -p /var/lib/kubelet
cp ${LOCATION_PATH}/var/lib/kubelet/kubeconfig /var/lib/kubelet

systemctl daemon-reload
systemctl enable kube-proxy kubelet
