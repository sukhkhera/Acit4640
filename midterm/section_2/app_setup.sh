#!/bin/bash
HICHAT_USER="hichat"
NGINX_FILE="/home/$HICHAT_USER/nginx.conf"
HOME_FOLDER="/app"
PASSWORD="disabled"

create_users() {
    ssh -i midterm_id_rsa -p 12922 \
        -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
        -q midterm exit "sudo useradd -m -d $HOME_FOLDER $HICHAT_USER -p $PASSWORD;"
}


install() {
    ssh -i midterm_id_rsa -p 12922 \
        -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
        -q midterm "sudo yum -y install git; \
                    sudo yum -y install npm; \
                    sudo yum -y install nodejs; \
                    sudo yum -y install nginx;"
}

git_clone() {
    ssh -i midterm_id_rsa -p 12922 \
        -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
        -q midterm "sudo chmod 777 $HOME_FOLDER; \
        cd $HOME_FOLDER; \
        sudo chown $HICHAT_USER $HOME_FOLDER; \
        git clone https://github.com/wayou/HiChat /$HOME_FOLDER; \
        cd /app; \
        npm install;"
}

start_services(){
    sudo systemctl enable nginx
    sudo systemctl daemon-reload
    sudo systemctl enable hichat

}

server_start() {
    sudo killall node
    cd /home/app
    node server.js
}

create_users
install
git_clone
start_services
server_start
