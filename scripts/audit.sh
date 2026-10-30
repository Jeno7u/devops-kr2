#!/usr/bin/env bash
set -u

failures=0

check() {
  description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS: %s\n' "$description"
  else
    printf 'FAIL: %s\n' "$description"
    failures=$((failures + 1))
  fi
}

echo '[1] Службы сервера'
check 'SSH работает' systemctl is-active --quiet ssh
check 'Nginx работает' systemctl is-active --quiet nginx
check 'Docker работает' systemctl is-active --quiet docker

echo '[2] Межсетевой экран'
check 'UFW активен' sh -c "sudo -n ufw status numbered | grep -q '^Status: active'"

echo '[3] Docker Engine'
check 'Docker Engine не ниже 28' sh -c "test \"$(docker version --format '{{.Server.Version}}' | cut -d. -f1)\" -ge 28"

echo '[4] Ресурс ПР № 6'
check 'Статический ресурс доступен по HTTPS' curl -fsS --cacert /home/devops/devops.crt --resolve devops.local:443:127.0.0.1 https://devops.local/

echo '[5] Ресурс ПР № 7'
check 'Контейнерное приложение доступно через Nginx' curl -fsS --cacert /home/devops/devops.crt --resolve devops.local:443:127.0.0.1 https://devops.local/app/

echo '[6] Контрольная работа № 2'
check 'Redis находится в состоянии healthy' sh -c 'cid=$(docker compose --project-directory /home/devops/kr2 ps -q redis); test -n "$cid" && test "$(docker inspect -f "{{.State.Health.Status}}" "$cid")" = healthy'
check 'Порт приложения опубликован только на 127.0.0.1' sh -c "docker compose --project-directory /home/devops/kr2 port app 8004 | grep -qx '127.0.0.1:8004'"
check 'Права файла .env равны 600' sh -c "stat -c '%a' /home/devops/kr2/.env | grep -qx '600'"
check 'Сертификат действует не менее 30 дней' openssl x509 -checkend 2592000 -noout -in /etc/ssl/certs/kr2.crt
check 'Ресурс kr2 активирован' test -L /etc/nginx/sites-enabled/kr2

exit "$failures"
