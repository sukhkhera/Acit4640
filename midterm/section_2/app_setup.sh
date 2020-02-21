#!/bin/bash
HICHAT_USER="hichat"
NGINX_FILE="/home/$HICHAT_USER/nginx.conf"
NGINX_DIR="/etc/nginx/"
HOME_FOLDER="/app"
PASSWORD="disabled"

create_users() {
    ssh midterm \
        "sudo useradd -p $(openssl passwd -1 disabled) -d $HOME_FOLDER hichat;"
}


install() {
    ssh midterm \
        "sudo yum -y install git; \
        sudo yum -y install npm; \
        sudo yum -y install nodejs; \
        sudo yum -y install nginx; \
        "
}

copy_files(){
    ssh midterm \
        "sudo cp -f $NGINX_FILE  $NGINX_DIR;"
}

git_clone() {
    ssh midterm \
        "sudo chmod 777 $HOME_FOLDER; \
        sudo chown $HICHAT_USER $HOME_FOLDER; \
        cd $HOME_FOLDER; \
        git clone https://github.com/wayou/HiChat /$HOME_FOLDER; \
        cd $HOME_FOLDER; \
        npm install; \
        "
}

start_services(){
    sudo systemctl enable nginx
    sudo systemctl enable hichat
    sudo systemctl daemon-reload
    sudo systemctl start nginx
    sudo systemctl start hichat
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