FROM tomcat:9

ARG VERSION=1.0.1

RUN wget -q http://192.168.50.2:8081/nexus/content/repositories/snapshots/test/app/${VERSION}/app-${VERSION}.war -O /usr/local/tomcat/webapps/app.war

EXPOSE 8080

CMD ["catalina.sh", "run"]