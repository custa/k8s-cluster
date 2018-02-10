#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

cp /vagrant/kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler} /usr/bin
mkdir -p /etc/kubernetes
\cp ${LOCATION_PATH}/etc/kubernetes/{config,apiserver,controller-manager,scheduler} /etc/kubernetes
cp ${LOCATION_PATH}/usr/lib/systemd/system/{kube-apiserver.service,kube-controller-manager.service,kube-scheduler.service} \
  /usr/lib/systemd/system/

systemctl daemon-reload
systemctl enable kube-apiserver kube-controller-manager kube-scheduler
