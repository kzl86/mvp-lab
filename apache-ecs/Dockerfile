FROM ubuntu:bionic

ENV TZ=Europe/Budapest

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
apt-get update && apt-get install apache2 php libapache2-mod-php wordpress -y

COPY wordpress.conf /etc/apache2/sites-available/

RUN a2ensite wordpress && \
a2enmod rewrite && \
service apache2 reload

RUN mkdir /etc/wordpress

COPY config.php /etc/wordpress/

EXPOSE 80/tcp

CMD /etc/init.d/apache2 start && tail -f /dev/null