#!/bin/bash
set -e

trap cleanup EXIT

cleanup()
{
    local exit=$?

    if [ -e $TEMP ]; then
        rm -rf $TEMP
    fi
    if [ -e $OLD ]; then
        rm -rf $OLD
    fi

    return $exit
}

check()
{   
    if grep -E -q '^nameserver 127.*.*.*|^nameserver localhost|^nameserver ::1' /etc/resolv.conf; then
        error DNS Checking loopback IP address 127.0.0.0/8, localhost or ::1 configured as the DNS server on the host file /etc/resolv.conf, can’t accept it
        exit 1
    fi
}

source ${CATTLE_HOME:-/var/lib/cattle}/common/scripts.sh

DEST=$CATTLE_HOME/pyagent
MAIN=$DEST/agent
STAMP=$CATTLE_HOME/.pyagent-stamp
OLD=$(mktemp -d ${DEST}.XXXXXXXX)
TEMP=$(mktemp -d ${DEST}.XXXXXXXX)

cd $(dirname $0)

stage()
{
    if [[ -n "${CURL_CA_BUNDLE}" && -e ./dist/websocket/cacert.pem ]]; then
        if [ ! -e ./dist/websocket/cacert.orig ]; then
            cp ./dist/websocket/cacert.pem ./dist/websocket/cacert.orig
        fi
        cat ./dist/websocket/cacert.orig ${CURL_CA_BUNDLE} > ./dist/websocket/cacert.pem
    fi

    cp -rf apply.sh bin/agent $TEMP

    find $TEMP -name "*.sh" -exec chmod +x {} \;
    find $TEMP \( -name host-api -o -name cadvisor -o -name nsenter -o -name socat \) -exec chmod +x {} \;

    if [ -e $DEST ]; then
        mv $DEST ${OLD}
    fi
    mv $TEMP ${DEST}
    rm -rf ${OLD}

    echo $RANDOM > $STAMP

}

conf()
{
    CONF=(${CATTLE_HOME}/pyagent/agent.conf
          /etc/cattle/agent/agent.conf
          ${CATTLE_HOME}/etc/cattle/agent/agent.conf
          /var/lib/rancher/etc/agent.conf)

    for conf_file in "${CONF[@]}"; do
        if [ -e $conf_file ]
        then
            source $conf_file
        fi
    done
}


start(){
    export PATH=${CATTLE_HOME}/bin:$PATH

    if [ "${CATTLE_CHECK_NAMESERVER}" = "false" ];then
        info Skipping DNS nameserver check
    else
        check
    fi
    
    
    chmod +x $MAIN
    if [ "$CATTLE_PYPY" = "true" ] && which pypy >/dev/null; then
        MAIN="pypy $MAIN"
    fi

    info Executing $MAIN
    cleanup

    $CATTLE_HOME/config.sh host-config

    exec $MAIN
}

conf

if [ "$1" = "start" ]; then
    start
else
    stage
fi
