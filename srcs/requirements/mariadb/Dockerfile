FROM	alpine:3.18

RUN	apk update && apk upgrade &&\
	apk add mariadb mariadb-client
	
COPY	./conf/configure-mariadb.sh /tmp/configure-mariadb.sh
RUN	chmod +x /tmp/configure-mariadb.sh

ENTRYPOINT	[ "sh", "/tmp/configure-mariadb.sh" ]
