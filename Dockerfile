FROM debian:buster

ENV  AUTOINDEX on

RUN apt-get update && apt-get install -y \
    nginx wget mariadb-server sysvinit-utils openssl vim\
    php-mysql \
    php-mbstring \
    php-xml-util \
    php-fpm && \
    mkdir /var/www/localhost && \
	openssl req -x509 \
	-nodes -days 30 \
	-subj "/C=JP" \
	-newkey rsa:2048 \
	-keyout /etc/ssl/ssl-k.key -out /etc/ssl/ssl-c.crt; 

RUN cd /var/www/localhost && \
	wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-english.tar.gz && \
	tar -xf phpMyAdmin-5.1.0-english.tar.gz && rm -rf phpMyAdmin-5.1.0-english.tar.gz && \
	mv phpMyAdmin-5.1.0-english /var/www/localhost/phpmyadmin

RUN	cd /var/www/localhost && \
    wget --no-check-certificate https://wordpress.org/latest.tar.gz  && \
	tar -xvzf latest.tar.gz && rm -rf latest.tar.gz 
    

COPY srcs/default /etc/nginx/sites-available
COPY srcs/config.inc.php /var/www/localhost/phpmyadmin
COPY srcs/wp-config.php /var/www/localhost/wordpress
COPY srcs/starter.sh .

RUN chown -R www-data:www-data /var/www/* && \
	chmod +x starter.sh

CMD sed -ie "s/autoindex on/autoindex $AUTOINDEX/" /etc/nginx/sites-available/default && \
    bash starter.sh