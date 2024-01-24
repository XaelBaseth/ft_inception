#!/bin/bash

#Replace the placeholder ${LOGIN} values in the given files by an actual value set in the Makefile.

sed -i "s/${LOGIN}/login/g" Makefile
sed -i "s/${LOGIN}/login/g" srcs/.env
sed -i "s/${LOGIN}/login/g" srcs/requirements/nginx/conf/default.conf
