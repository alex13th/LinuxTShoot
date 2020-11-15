#!/bin/bash

{
grep vasya /etc/passwd || useradd vasya

touch  /home/vasya/trash
chattr  +i /home/vasya/trash
} &>/dev/null

