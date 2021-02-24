FROM ubuntu:bionic

ENV TZ=Europe/Budapest

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install apache2 php libapache2-mod-php -y

EXPOSE 80/tcp

CMD /etc/init.d/apache2 start && tail -f /dev/null