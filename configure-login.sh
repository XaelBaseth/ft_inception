#!/bin/bash

#replace the occurence of the ${LOGIN} by its values in the given file.

sed -i "s/login/${LOGIN}/g" srcs/.env
sed -i "s/login/${LOGIN}/g" srcs/requirements/nginx/conf/default.conf

