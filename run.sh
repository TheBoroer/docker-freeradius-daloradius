#!/bin/bash
echo "start init"

# Run init.sh once then remove the line from run.sh
/init.sh
sed -i "s/^\/init.sh//" /run.sh

# Update DB Values for FreeRadius
cp /etc/freeradius/3.0/mods-available/sql.default /etc/freeradius/3.0/mods-available/sql
sed -i -e 's/server = "localhost"/server = "'$MYSQL_HOST'"/g' /etc/freeradius/3.0/mods-available/sql
sed -i -e 's/#port = 3306/port = '$MYSQL_PORT'/g' /etc/freeradius/3.0/mods-available/sql
sed -i -e 's/login = "radius"/login = "'$MYSQL_USER'"/g' /etc/freeradius/3.0/mods-available/sql
sed -i -e 's/password = "radpass"/password = "'$MYSQL_PASS'"/g' /etc/freeradius/3.0/mods-available/sql
sed -i -e 's/radius_db = "radius"/radius_db = "'$MYSQL_DATABASE'"/g' /etc/freeradius/3.0/mods-available/sql

# Update DB Values or daloRADIUS
cp /var/www/daloradius/library/daloradius.conf.php.default /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/\$configValues\['CONFIG_DB_HOST'\] = 'localhost';/\$configValues\['CONFIG_DB_HOST'\] = '"$MYSQL_HOST"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/\$configValues\['CONFIG_DB_PORT'\] = '3306';/\$configValues\['CONFIG_DB_PORT'\] = '"$MYSQL_PORT"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/\$configValues\['CONFIG_DB_USER'\] = 'root';/\$configValues\['CONFIG_DB_USER'\] = '"$MYSQL_USER"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/\$configValues\['CONFIG_DB_PASS'\] = '';/\$configValues\['CONFIG_DB_PASS'\] = '"$MYSQL_PASS"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/\$configValues\['CONFIG_DB_NAME'\] = 'radius';/\$configValues\['CONFIG_DB_NAME'\] = '"$MYSQL_DATABASE"';/" /var/www/daloradius/library/daloradius.conf.php

mkdir /run/php & 
php-fpm7.2 & 
nginx & 
/usr/sbin/freeradius -X


