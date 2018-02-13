#!/bin/bash

/usr/sbin/nginx -t
/usr/sbin/nginx

/usr/bin/bash -c 'mkdir -p /run/uwsgi; chown USERNAME_PLACEHOLDER:nginx /run/uwsgi'
/usr/bin/uwsgi --emperor /etc/uwsgi/sites