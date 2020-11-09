#!/bin/bash

dd if=/dev/zero of=/dev/sda bs=446 count=1 >/dev/null
sleep 4
echo "reboo the VM"

