#!/bin/bash
#This is a shortcut function that makes it shorter and more readable
vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

# If you are using a Mac, you can just use

NET_NAME="NETMIDTERM"
VM_NAME="MIDTERM4640"
NEW_VM_NAME="A00871245"

SSH_PORT="12922"
WEB_PORT="12980"

create_network () {
    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.10.0/24 --dhcp off \
    --port-forward-4 "SSH:tcp:[127.0.0.1]:"$SSH_PORT":[192.168.10.10]:22" \
    --port-forward-4 "HTTP:tcp:[127.0.0.1]:"$WEB_PORT":[192.168.10.10]:80" \

}

create_vm () {
    vbmg modifyvm "$VM_NAME" --name "$NEW_VM_NAME" --nic1 "natnetwork" --nat-network1 "$NET_NAME"
}

echo "Starting script..."

# clean_all
create_network
create_vm

echo "DONE!"