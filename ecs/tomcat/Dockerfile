FROM centos

RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat

RUN curl -O https://downloads.apache.org/tomcat/tomcat-8/v8.5.64/bin/apache-tomcat-8.5.64.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-8.5.64/* /opt/tomcat/.

RUN yum install java -y
RUN java -version

RUN useradd -ms /bin/bash tomcat
USER tomcat

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]