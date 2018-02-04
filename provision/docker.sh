#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

# https://docs.docker.com/install/linux/docker-ce/centos/#install-using-the-repository
yum -y install device-mapper-persistent-data
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce-17.12.0.ce

systemctl daemon-reload
systemctl enable docker
