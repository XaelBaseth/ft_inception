#!/bin/sh

if [! -f "/etc/vsftpd/vsftpd.conf.bak" ]; then
	mkdir -p /var/www/html
	cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
	mv /tmp/vsftpd.cong /etc/vsftpd/vsftpd.conf

	adduser $FTP_USR --disabled-password
	echo "$FTP_USR:$FTP_PWD" | /usr/sbin/chpasswd &> /dev/null
	chown -R $FTP_USR:$FTP_USR /var/www/html
	echo $FTP_USR | tee -a /etc/vsftpd.userlist &> /dev/null
fi

echo "FTP started on :21"
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
