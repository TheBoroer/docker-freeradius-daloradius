FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  mysql-client libmysqlclient-dev \
  nginx php php7.2-fpm php-common php-gd php-curl php-mail php-mail-mime php-pear php-db php-mysqlnd \
  freeradius freeradius-mysql freeradius-utils \
  wget unzip && \
  pear install DB && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cpan	

ENV MYSQL_HOST "localhost"
ENV MYSQL_PORT "3306"
ENV MYSQL_DATABASE "radius"
ENV MYSQL_USER "root"
ENV MYSQL_PASS ""
ENV CLIENT_NET1 "0.0.0.0/0"
ENV CLIENT_SECRET "testing123"
ENV CLIENT_MAX_CONNECTIONS "16"
ENV CLIENT_IDLE_TIMEOUT "30"


RUN wget https://github.com/lirantal/daloradius/archive/master.zip && \
	unzip *.zip && \
	mv daloradius-master /var/www/daloradius && \
 	chown -R www-data:www-data /var/www/daloradius && \
	chmod 644 /var/www/daloradius/library/daloradius.conf.php && \
	rm /etc/nginx/sites-enabled/default

COPY init.sh /
COPY run.sh /
RUN chmod +x /init.sh && chmod +x /run.sh
COPY etc/nginx/radius.conf /etc/nginx/sites-enabled/

# Enable Additional FreeRadius Mods
RUN ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql


EXPOSE 1812 1813 80

ENTRYPOINT ["/run.sh"]
