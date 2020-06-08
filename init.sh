#!/bin/bash
sleep 5

MYSQL="mysql -u$MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST --port $MYSQL_PORT" 
echo $MYSQL
$MYSQL -e \
"CREATE DATABASE radius; GRANT ALL ON $MYSQL_USER.* TO radius@localhost IDENTIFIED BY '$MYSQL_PASS'; \
flush privileges;"

$MYSQL $MYSQL_DATABASE  < /etc/freeradius/sql/mysql/schema.sql
$MYSQL $MYSQL_DATABASE  < /etc/freeradius/sql/mysql/nas.sql
$MYSQL $MYSQL_DATABASE  < /var/www/daloradius/contrib/db/mysql-daloradius.sql



sed -i -e 's/server = "localhost"/server = "'$MYSQL_HOST'"/g' /etc/freeradius/sql.conf
sed -i -e 's/#port = 3306/port = '$MYSQL_PORT'/g' /etc/freeradius/sql.conf
sed -i -e 's/login = "radius"/login = "'$MYSQL_USER'"/g' /etc/freeradius/sql.conf
sed -i -e 's/password = "radpass"/password = "'$MYSQL_PASS'"/g' /etc/freeradius/sql.conf
sed -i -e 's/radius_db = "radius"/radius_db = "'$MYSQL_DATABASE'"/g' /etc/freeradius/sql.conf
sed -i -e 's/$INCLUDE sql.conf/\n$INCLUDE sql.conf/g' /etc/freeradius/radiusd.conf
sed -i -e 's|$INCLUDE sql/mysql/counter.conf|\n$INCLUDE sql/mysql/counter.conf|g' /etc/freeradius/radiusd.conf
sed -i -e 's|authorize {|authorize {\nsql|' /etc/freeradius/sites-available/inner-tunnel
sed -i -e 's|session {|session {\nsql|' /etc/freeradius/sites-available/inner-tunnel 
sed -i -e 's|authorize {|authorize {\nsql|' /etc/freeradius/sites-available/default
sed -i -e 's|session {|session {\nsql|' /etc/freeradius/sites-available/default
sed -i -e 's|accounting {|accounting {\nsql|' /etc/freeradius/sites-available/default

sed -i -e 's|auth_badpass = no|auth_badpass = yes|g' /etc/freeradius/radiusd.conf
sed -i -e 's|auth_goodpass = no|auth_goodpass = yes|g' /etc/freeradius/radiusd.conf
sed -i -e 's|auth = no|auth = yes|g' /etc/freeradius/radiusd.conf

sed -i -e 's|\t#  See "Authentication Logging Queries" in sql.conf\n\t#sql|#See "Authentication Logging Queries" in sql.conf\n\tsql|g' /etc/freeradius/sites-available/inner-tunnel 
sed -i -e 's|\t#  See "Authentication Logging Queries" in sql.conf\n\t#sql|#See "Authentication Logging Queries" in sql.conf\n\tsql|g' /etc/freeradius/sites-available/default

sed -i -e 's|sqltrace = no|sqltrace = yes|g' /etc/freeradius/sql.conf



sed -i -e "s/readclients = yes/nreadclients = yes/" /etc/freeradius/sql.conf
echo -e "\nATTRIBUTE Usage-Limit 3000 string\nATTRIBUTE Rate-Limit 3001 string" >> /etc/freeradius/dictionary



#================DALORADIUS=========================
sed -i -e "s/$configValues\['CONFIG_DB_PASS'\] = '';/$configValues\['CONFIG_DB_PASS'\] = '"$MYSQL_PASS"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/$configValues\['CONFIG_DB_USER'\] = 'root';/$configValues\['CONFIG_DB_USER'\] = '"$MYSQL_USER"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/$configValues\['CONFIG_DB_HOST'\] = 'localhost';/$configValues\['CONFIG_DB_HOST'\] = '"$MYSQL_HOST"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/$configValues\['CONFIG_DB_PORT'\] = '3306';/$configValues\['CONFIG_DB_PORT'\] = '"$MYSQL_PORT"';/" /var/www/daloradius/library/daloradius.conf.php
sed -i -e "s/$configValues\['CONFIG_DB_NAME'\] = 'radius';/$configValues\['CONFIG_DB_NAME'\] = '"$MYSQL_DATABASE"';/" /var/www/daloradius/library/daloradius.conf.php




# if [ -n "$CLIENT_NET" ]; then
# echo "client $CLIENT_NET { 
#     	secret          = $CLIENT_SECRET 
#     	shortname       = clients 
# }" >> /etc/freeradius/clients.conf
# fi 

# Parse the multiple CLIENT_NETx variables and append them to the configuration
env | grep 'CLIENT_NET' | sort | while read extraline; do
    echo "# $extraline " >> /etc/freeradius/clients.conf
    line=$(echo $extraline | cut -d'=' -f2-)
    echo "client $line { 
        	secret = $CLIENT_SECRET 
    }" >> /etc/freeradius/clients.conf
done


mkdir /run/php

echo "Initialized"