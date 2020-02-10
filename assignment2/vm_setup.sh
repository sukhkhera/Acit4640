ADMIN_USER="admin"
TODOAPP_USER="todoapp"
CONFIG_DIR="/home/admin/app/config"
NGINX_DIR="/etc/nginx"
SERVICE_DIR="/etc/systemd/system"
DATABASE_FILE="/home/admin/acit4640/setup/database.js"
NGINX_FILE="/home/admin/acit4640/setup/nginx.conf"
SERVICE_FILE="/home/admin/acit4640/setup/todoapp.service"



create_users() {
    sudo useradd "$TODOAPPUSR" -p "P@ssw0rd"
    sudo usermod -a -G wheel "$TODOAPP_USER"
}

install() {
    sudo yum -y install git
    sudo yum -y install npm
    sudo yum -y install nodejs
    sudo yum -y install mongodb-server
    sudo yum -y install nginx
    sudo systemctl enable mongod
    sudo systemctl start mongod
}

firewall() {
    sudo firewall-cmd --zone=public --add-port=80/tcp
    sudo firewall-cmd --zone=public --add-port=8080/tcp
    sudo firewall-cmd --zone=public --add-service=https
    sudo firewall-cmd --zone=public --add-service=ssh
    sudo firewall-cmd --zone=public --add-service=http 
}

setup() {
    sudo mkdir /home/todoapp/app
    sudo chmod 755 /home/todoapp
    sudo chmod 777 /home/todoapp/app
    git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app
    cd /home/todoapp
    sudo chown todoapp app
    cd /home/todoapp/app
    npm install
}

copy_files() {
    sudo cp -f "$DATABASE_FILE" "$CONFIG_DIR"
    sudo cp -f "$NGINX_FILE" "$NGINX_DIR"
    sudo cp -f "$SERVICE_FILE" "$SERVICE_DIR"
}

start_services(){
    sudo systemctl enable nginx
    sudo systemctl daemon-reload
    sudo systemctl enable todoapp
    sudo systemctl start todoapp
    sudo systemctl start nginx
}

server_start() {
    sudo killall node
    cd /home/todoapp/app
    node server.js
}

create_users
install
firewall
setup
copy_files
start_services
server_start
