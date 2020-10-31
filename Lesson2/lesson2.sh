#!/bin/bash

{
sed -i '/Wants/a Requisite=vsftpd.service' /usr/lib/systemd/system/sshd.service

systemctl daemon-reload
systemctl stop sshd.service
} &> /dev/null

echo `date +%s | sha256sum | base64 | head -c 32` | passwd --stdin root >/dev/null

echo try to start sshd.service

