#!/bin/bash

PXE_NAME="PXE_4640"
VM_NAME="VM4640"

vbmg () { VBoxManage.exe "$@"; }
#BUILD VBOX
start_vbox(){
    ./vbox_setup.sh
}

#Starting PXE
start_pxe(){
    vbmg startvm "$PXE_NAME"

    while /bin/true; do
        ssh -i acit_admin_id_rsa -p 12222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q pxe exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 2
        else
                break
        fi
    done
}

#COPYING FILES TO THE PXE SERVER
copy_files(){
    ssh -i acit_admin_id_rsa -p 12222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q pxe exit "sudo chmod -R 755 /var/www/lighttpd/; \
                    sudo chown admin /var/www/lighttpd/files; \
                    sudo cp /home/admin/acit_admin_id_rsa.pub /var/www/lighttpd/files; \
                    sudo cp /home/admin/.ssh/authorized_keys /var/www/lighttpd/files; 
                    sudo chmod 755 /home/admin/acit_admin_id_rsa.pub\
                    "

    scp ks.cfg pxe:/var/www/lighttpd/files

    scp nginx.conf pxe:/var/www/lighttpd/files

    scp database.js pxe:/var/www/lighttpd/files

    scp todoapp.service pxe:/var/www/lighttpd/files

    scp acit_admin_id_rsa.pub pxe:/var/www/lighttpd/files

}
echo "Copying Files"

check_vm_up(){
    vbmg startvm "$VM_NAME"

    while /bin/true; do
        ssh -i acit_admin_id_rsa -p 12022 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q todoapp exit
        if [ $? -ne 0 ]; then
                echo " VM is not up, trying again..."
                sleep 20
        else
            vbmg controlvm "$PXE_NAME" shutdown
            break
        fi
    done
}

start_vbox
start_pxe
copy_files
check_vm_up


