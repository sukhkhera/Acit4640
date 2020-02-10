#!/bin/bash
#This is a shortcut function that makes it shorter and more readable
vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

# If you are using a Mac, you can just use

NET_NAME="4640"
VM_NAME="VM4640"
OS_TYPE="RedHat_64"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")
CREATE_PATH=$(dirname "$VBOX_FILE")
ISO_FILE="C:\Users\Sukh\Documents\ACIT 4640\CentOS-7-x86_64-Minimal-1908.iso"

SSH_PORT="12022"
PXE_PORT="12222"
WEB_PORT="12080"
WEB_PORT2="12081"

#This function will clean the NAT network and the virtual machine
clean_all () {
    vbmg natnetwork remove --netname $NET_NAME
    vbmg unregistervm $VM_NAME --delete
}

create_network () {
    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.230.0/24 --dhcp off \
    --port-forward-4 "SSH:tcp:[127.0.0.1]:"$SSH_PORT":[192.168.230.10]:22" \
    --port-forward-4 "PXE:tcp:[127.0.0.1]:"$PXE_PORT":[192.168.230.200]:22" \
    --port-forward-4 "HTTP:tcp:[127.0.0.1]:"$WEB_PORT":[192.168.230.10]:80" \
    --port-forward-4 "HTTP:tcp:[127.0.0.1]:"$WEB_PORT2":[192.168.230.200]:80" \

}

create_vm () {
    vbmg createvm --name "$VM_NAME" --ostype $OS_TYPE --register
    vbmg modifyvm "$VM_NAME" --memory 1500 --cpus 1 --cableconnected2 on --audio "none" --nic1 "natnetwork" --nat-network1 "$NET_NAME" --boot1 disk --boot2 net
    
    vbmg createmedium disk --filename "$VM_NAME".vdi --format VDI --size 10240

    # vbmg modifymedium disk "$VM_NAME.vdi" --move "$VM_DIR"

    vbmg storagectl $VM_NAME --name "IDEController" --add ide

    vbmg storageattach $VM_NAME --storagectl "IDEController" --port 1 --device 0 --type "dvddrive" --medium emptydrive
    
    vbmg storagectl $VM_NAME --name "SATAController" --add sata

    vbmg storageattach $VM_NAME --storagectl "SATAController" --port 0 --device 0 --type "hdd" --medium "$VM_DIR/$VM_NAME".vdi
}

echo "Starting script..."

clean_all
create_network
create_vm

echo "DONE!"