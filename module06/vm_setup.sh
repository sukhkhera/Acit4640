ADMIN_USER="admin"
TODOAPP_USER="todoapp"
CONFIG_DIR="/home/todoapp/app/config"
NGINX_DIR="/etc/nginx"
SERVICE_DIR="/etc/systemd/system"
DATABASE_FILE="/home/admin/database.js"
NGINX_FILE="/home/admin/nginx.conf"
SERVICE_FILE="/home/admin/todoapp.service"



create_users() {
    # sudo useradd "$ADMIN_USER" -p "P@ssw0rd"
    # sudo useradd "$TODOAPP_USER" -p "P@ssw0rd"
    sudo usermod -a -G wheel "$TODOAPP_USER"
    sudo usermod -a -G wheel "$ADMIN_USER"
}

install() {
    sudo yum -y install git
    sudo yum -y install npm
    sudo yum -y install nodejs
    sudo yum -y install mongodb-server
    sudo yum -y install mongodb
    sudo yum -y install nginx
    sudo yum -y install psmisc
    sudo systemctl enable mongod
    sudo systemctl start mongod
}

curl_mongodb_acit4640() {
    curl -O -u BCIT:w1nt3r2020 https://acit4640.y.vu/docs/module06/resources/mongodb_ACIT4640.tgz /home/admin

    cd /home/admin
    tar zxf mongodb_ACIT4640.tgz

    export LANG=C
    mongorestore -d acit4640 /home/admin/ACIT4640

}

# firewall() {
#     sudo firewall-cmd --zone=public --add-port=80/tcp
#     sudo firewall-cmd --zone=public --add-port=8080/tcp
#     sudo firewall-cmd --zone=public --add-service=https
#     sudo firewall-cmd --zone=public --add-service=ssh
#     sudo firewall-cmd --zone=public --add-service=http
    
# }

setup() {
    # sudo mkdir /home/todoapp/app
    sudo chmod 755 /home/todoapp
    sudo chmod 777 /home/todoapp/app
    git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app
    cd /home/todoapp
    sudo chown todoapp app
    cd /home/todoapp/app
    npm install

    setenforce 0
    SELINUX=permissive
}

copy_files() {
    sudo cp -f "$DATABASE_FILE" "$CONFIG_DIR"
    sudo cp -f "$NGINX_FILE" "$NGINX_DIR"
    sudo cp -f "$SERVICE_FILE" "$SERVICE_DIR"
}

start_services(){
    sudo killall node
    sudo killall nginx
    sudo systemctl enable nginx
    sudo systemctl daemon-reload
    sudo systemctl enable todoapp
    sudo systemctl start todoapp
    sudo systemctl restart nginx
}

server_start() {
    cd /home/todoapp/app
    node server.js
}

create_users
install
# firewall
curl_mongodb_acit4640
setup
copy_files
start_services
server_start
