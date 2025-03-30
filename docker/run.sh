#!/bin/bash

# in order to use npm and node, load $NVM_SH which is /home/${USER}/.nvm/nvm.sh since bashrc not working because the shell is not interactive
. $NVM_SH

cd /var/www/html/ || exit

composer install --no-dev --no-interaction --no-ansi --audit

composer clear-cache

composer dump-autoload --optimize

initialStuff() {
    if grep -q "^APP_KEY=" .env; then
      # Extract the value of APP_KEY
      APP_KEY_VALUE=$(grep "^APP_KEY=" .env | cut -d '=' -f2)

      # Check if the value is empty
      if [ -z "$APP_KEY_VALUE" ]; then
        echo "APP_KEY is empty. Generating a new key..."
        php artisan key:generate --ansi --force
      fi
    else
      echo "APP_KEY is not set. Generating a new key..."
      php artisan key:generate --ansi --force
    fi

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

# runAnotherNPMPackage(){
#     if [ -f ./app/Console/Commands/Export/Charts/package-lock.json ]; then
#       echo 'exists' && \
#       cd app/Console/Commands/Export/Charts && npm install
#     fi
# }

initialStuff

# runAnotherNPMPackage

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisor-app.conf
