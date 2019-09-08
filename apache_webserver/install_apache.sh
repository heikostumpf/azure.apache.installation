#!/bin/bash

apt-get update

apt-get install apache2 -y

apt-get install php libapache2-mod-php -y

service apache2 start

rm /var/www/html/index.html

# clone from git 

service apache2 start