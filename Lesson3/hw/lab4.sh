#!/bin/bash
lvresize -L -300M /dev/centos/root -f -n >/dev/null 2>&1
lvresize -L -300M /dev/mapper/cl-root -f -n >/dev/null 2>&1

echo "Reboot your system now"
