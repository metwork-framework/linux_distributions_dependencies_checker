#!/bin/bash

IMAGE=$1
BASE=$(echo "${IMAGE}" |awk -F ':' '{print $1;}')
if test "${BASE}" = "debian"; then
    BACKEND="apt-get"
elif test "${BASE}" = "ubuntu"; then
    BACKEND="apt-get"
elif test "${BASE}" = "fedora"; then
    BACKEND="yum"
elif test "${BASE}" = "centos"; then
    BACKEND="yum"
elif test "${BASE}" = "opensuse/leap"; then
    BACKEND="zypper"
else
    echo "ERROR: can't find a backend for ${BASE}"
    exit 1
fi

if test "${BACKEND}" = "apt-get"; then
    echo "***** PREPARING *****"
    echo
    if test "${BASE}" = "ubuntu"; then
        cat /etc/apt/sources.list |grep -v '^#' |sed 's~http[^ ]* ~mirror://mirrors.ubuntu.com/mirrors.txt ~g' >/etc/apt/sources.list2
        mv -f /etc/apt/sources.list2 /etc/apt/sources.list
    fi
    apt-get update
    apt-get -y install apt-file
    apt-file update
    echo
    echo
fi

echo "***** TESTING *****"
echo

RES=0
for DEP in $(cat list.txt); do
    FOUND=0
    for REP in /usr/lib64 /lib64 /usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu; do
        if test -f "${REP}/${DEP}"; then
            FOUND=1
            break
        fi
    done
    if test "${FOUND}" = "0"; then
        if test "${BACKEND}" = "yum"; then
            OUTPUT=$( ( yum provides --quiet --noplugins "${DEP}" 2>&1) |grep -v ^Error )
            test "${OUTPUT}" != ""
            NOT_FOUND=$?
        elif test "${BACKEND}" = "apt-get"; then
            apt-file search "${DEP}" >/dev/null 2>&1
            NOT_FOUND=$?
        elif test "${BACKEND}" = "zypper"; then
            zypper se --provides  "${DEP}" >/dev/null 2>&1
            NOT_FOUND=$?
        fi
    else
        NOT_FOUND=1
    fi
    if test "${NOT_FOUND}" != "0"; then
        echo "- Can't find: ${DEP} in ${IMAGE}"
        RES=1
    else
        echo "- ok for ${DEP} in ${IMAGE}"
    fi
done

exit ${RES}
