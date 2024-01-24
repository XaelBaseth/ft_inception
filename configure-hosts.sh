#!/bin/bash

#loopback the address in the /etc/hosts/ in order to use the domain name instead of the ip address.

if ! grep -q ${DOMAIN} "/etc/hosts"; then
	echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts
fi
