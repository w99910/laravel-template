#!/bin/bash

# in order to use npm and node, load $NVM_SH which is /home/${USER}/.nvm/nvm.sh since bashrc not working because the shell is not interactive
. $NVM_SH

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

    if [ -f ./package-lock.json ]; \
      then \
        npm ci --loglevel=error --no-audit; \
      else \
        npm install --loglevel=error --no-audit; \
    fi

    npm run build
}

initialStuff

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisor-app.conf
