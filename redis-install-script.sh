#!/bin/bash
# From here: http://www.codingsteps.com/install-redis-2-6-on-amazon-ec2-linux-ami-or-centos/
# Thanks to https://raw.github.com/gist/2776679/b4f5f5ff85bddfa9e07664de4e8ccf0e115e7b83/install-redis.sh
# Uses redis-server init script from https://raw.github.com/matthewbga/install-redis-amazon-linux-centos/master/redis-server
###############################################
# To use: 
# wget https://raw.github.com/matthewbga/install-redis-amazon-linux-centos/master/redis-install-script.sh
# chmod 777 redis-install-script.sh
# ./redis-install-script.sh
###############################################
version=4.0.6
ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

echo "*****************************************"
echo " 1. Prerequisites: Install updates, set time zones, install GCC and make"
echo "*****************************************"
sudo yum -y update
sudo ln -sf /usr/share/zoneinfo/EST5EDT /etc/localtime
sudo yum -y install gcc gcc-c++ make 
echo "*****************************************"
echo " 2. Download, Untar and Make Redis $version"
echo "*****************************************"
sudo wget http://download.redis.io/releases/redis-$version.tar.gz
sudo tar xzf redis-$version.tar.gz
sudo rm redis-$version.tar.gz -f
cd redis-$version
sudo make
sudo make install
echo "*****************************************"
echo " 3. Create Directories and Copy Redis Files"
echo "*****************************************"
sudo mkdir /etc/redis /var/lib/redis
sudo cp src/redis-server src/redis-cli /usr/local/bin
sudo cp redis.conf /etc/redis
echo "*****************************************"
echo " 4. Configure Redis.Conf"
echo "*****************************************"
echo " Edit redis.conf as follows:"
echo " 1: ... daemonize yes"
echo " 2: ... bind $ip"
echo " 3: ... dir /var/lib/redis"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis.log"
echo "*****************************************"
sudo echo "logfile /var/log/redis.log" >> redis.conf
sudo echo "loglevel verbose" >> redis.conf
sudo sed -e "s/^daemonize no$/daemonize yes/" -e "s/bind 127\.0\.0\.1/bind $ip/g" -e "s/^dir \.\//dir \/var\/lib\/redis\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis.log/" redis.conf > /etc/redis/redis.conf
echo "*****************************************"
echo " 5. Download init Script"
echo "*****************************************"
wget https://raw.github.com/matthewbga/install-redis-amazon-linux-centos/master/redis-server
echo "*****************************************"
echo " 6. Move and Configure Redis-Server"
echo "*****************************************"
sudo mv redis-server /etc/init.d
sudo chmod 755 /etc/init.d/redis-server
echo "*****************************************"
echo " 7. Auto-Enable Redis-Server"
echo "*****************************************"
sudo chkconfig --add redis-server
sudo chkconfig --level 345 redis-server on
echo "*****************************************"
echo " 8. Start Redis Server"
echo "*****************************************"
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sudo sysctl vm.overcommit_memory=1
sudo service redis-server start
echo "*****************************************"
echo " Installation Complete!"
echo " You can test your redis installation using the redis console:"
echo "   $ src/redis-cli"
echo "   redis> ping"
echo "   PONG"
echo "*****************************************"
echo " Following changes have been made in redis.config:"
echo " 1: ... daemonize yes"
echo " 2: ... bind $ip"
echo " 3: ... dir /var/lib/redis"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis.log"
echo "*****************************************"
#read -p "Press [Enter] to continue..."

