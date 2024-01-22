FROM debian:buster

RUN apt-get update
RUN apt-get install -y mariadb-server \
	mariadb-client \
	vim \
	&& rm -rf /var/lib/apt/lists/*

#Allow the daemon of mysql to run
#Purge and recreate the /var/lib/mysql with appropriate ownership
#Make sure that /var/run/mysqld is writable
RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld

EXPOSE 3306

COPY ./tools/mariadb.sh /usr/local/bin/
COPY ./conf/wordpress.sql /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh
RUN chmod +x /usr/local/bin/wordpress.sql

ENTRYPOINT [ "/usr/local/bin/mariadb.sh" ]

#Command to launch mariadb and enable the database to listen globally
CMD ["mysqld", "--bind-address=0.0.0.0"]
