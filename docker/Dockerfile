ARG PHP_VERSION=8.3
ARG COMPOSER_VERSION=latest
ARG NODE_VERSION=20-alpine
ARG TZ=UTC

FROM composer:${COMPOSER_VERSION} AS vendor

FROM php:${PHP_VERSION}-cli-bookworm AS base

ENV ROOT=/var/www/html
ENV USER=octane
ARG TZ=UTC

WORKDIR ${ROOT}

RUN apt-get update; \
  apt-get upgrade -yqq; \
  apt-get install -yqq --no-install-recommends --show-progress \
  apt-utils \
  curl \
  wget \
  nano \
  ca-certificates \
  supervisor \
  libsodium-dev \
  gnupg2

RUN apt-get -y autoremove \
      && apt-get clean \
      && docker-php-source delete \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
      && rm /var/log/lastlog /var/log/faillog

RUN echo ${TZ} > /etc/timezone

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions mbstring imagick mongodb  zip curl redis bcmath swoole xml gd pcntl sockets

RUN wget -q "https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64" \
  -O /usr/bin/supercronic \
  && chmod +x /usr/bin/supercronic \
  && mkdir -p /etc/supercronic \
  && echo "*/1 * * * * php ${ROOT}/artisan schedule:run --verbose --no-interaction" > /etc/supercronic/laravel

RUN cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini

COPY . .

RUN mkdir -p \
  storage/framework/{sessions,views,cache,testing} \
  storage/logs \
  bootstrap/cache && chmod -R a+rw storage && \
  mkdir /var/{log,run}

RUN chown -R www-data:www-data storage && \
    chmod -R 755 storage

RUN groupadd --force -g 1000 ${USER} && \
    useradd -ms /bin/bash --no-user-group --no-log-init -g www-data -u 1000 ${USER}

RUN mkdir -p /var/log/supervisor /var/{log,run} && touch /var/log/supervisor/supervisord.log /var/run/supervisord.pid \
  && chown ${USER} /var/log/supervisor/supervisord.log /var/run/supervisord.pid

RUN test -f /var/log/supervisor/supervisord.log || exit

COPY --chown=${USER}:${USER} --from=vendor /usr/bin/composer /usr/bin/composer

RUN test -d vendor || mkdir vendor

RUN chown -R ${USER}:www-data . \
    && find . -type f -exec chmod 664 {} \; \
    && find . -type d -exec chmod 775 {} \; \
    && chgrp -R www-data bootstrap/cache storage \
    && chmod -R ug+rwx storage bootstrap/cache


######### Install NPM #################
USER ${USER}

WORKDIR /home/${USER}

ENV NVM_DIR /home/${USER}/.nvm

ENV NVM_SH $NVM_DIR/nvm.sh

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

RUN export NVM_DIR=$NVM_DIR && \. $NVM_SH \
    && nvm install --lts
#######################################

WORKDIR ${ROOT}
# COPY run script
COPY --chown=${USER}:${USER} ./docker/run.sh /usr/bin/run

RUN test -f /usr/bin/run || exit && chmod +x /usr/bin/run

COPY --chown=${USER}:${USER} docker/conf/ /etc/supervisor/conf.d/

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["run"]

HEALTHCHECK --start-period=5s --interval=2s --timeout=5s --retries=8 CMD php artisan octane:status || exit 1
