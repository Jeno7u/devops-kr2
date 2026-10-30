#!/usr/bin/env bash
set -euo pipefail

set -x
openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 \
  -subj '/CN=kv.devops.local' \
  -addext 'subjectAltName=DNS:kv.devops.local' \
  -keyout /etc/ssl/private/kr2.key \
  -out /etc/ssl/certs/kr2.crt
chown root:root /etc/ssl/private/kr2.key /etc/ssl/certs/kr2.crt
chmod 600 /etc/ssl/private/kr2.key
chmod 644 /etc/ssl/certs/kr2.crt
install -m 644 /home/devops/kr2/deploy/nginx/kr2 /etc/nginx/sites-available/kr2
ln -sfn /etc/nginx/sites-available/kr2 /etc/nginx/sites-enabled/kr2
nginx -t
systemctl reload nginx
ls -l /etc/ssl/private/kr2.key /etc/ssl/certs/kr2.crt /etc/nginx/sites-enabled/kr2
openssl x509 -in /etc/ssl/certs/kr2.crt -noout -subject -ext subjectAltName
