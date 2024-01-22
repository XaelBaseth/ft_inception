FROM debian:buster

#Update and install the dependencies for nginx and openssl.
RUN apt-get update
RUN apt-get install -y nginx openssl

#Create the SSL certificate and private key
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
	-out /etc/nginx/ssl/acharlot.crt \
	-keyout /etc/nginx/ssl/acharlot.key \
	-subj "/C=FR/ST=Normandie/L=Normandie/O=42/OU=42/CN=acharlot.42.fr/UID=acharlot/"

RUN mkdir -p /var/run/nginx

COPY /conf/nginx.conf /etc/nginx/nginx.conf

#Only entry point allowed
EXPOSE 443

#start nginx without the daemon.
CMD ["nginx", "-g", "daemon off;"]
