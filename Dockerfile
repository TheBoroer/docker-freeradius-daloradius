FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
  mysql-client libmysqlclient-dev \
  nginx php php-common php-gd php-curl php-mail php-mail-mime php-pear php-db php-mysqlnd \
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
ENV CLIENT_SECRET testing123


RUN wget https://github.com/lirantal/daloradius/archive/master.zip && \
	unzip *.zip && \
	mv daloradius-master /var/www/daloradius && \
 	chown -R www-data:www-data /var/www/daloradius && \
	chmod 644 /var/www/daloradius/library/daloradius.conf.php && \
	rm /etc/nginx/sites-enabled/default

#	cp -R /var/www/daloradius/contrib/chilli/portal2/hotspotlogin /var/www/daloradius

COPY init.sh /	
COPY run.sh /	
RUN chmod +x /init.sh && chmod +x /run.sh
COPY etc/nginx/radius.conf /etc/nginx/sites-enabled/

EXPOSE 1812 1813 80

ENTRYPOINT ["/run.sh"]
