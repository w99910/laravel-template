#!/bin/bash

cd /var/www/html/ || exit

composer install --no-dev --no-interaction --no-ansi --audit

composer clear-cache

initialStuff() {
    php artisan key:generate --ansi; \
    php artisan optimize:clear; \
    php artisan event:cache; \
    php artisan config:cache; \
    php artisan route:cache; \
    php artisan storage:link
}

initialStuff

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisor-app.conf
