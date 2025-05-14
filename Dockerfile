ARG COMPOSER_VERSION=lts
ARG FRANKENPHP_TAG=latest

FROM composer:$COMPOSER_VERSION AS composer

FROM dunglas/frankenphp:$FRANKENPHP_TAG AS frankenphp_base
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --link frankenphp/10-php.ini $PHP_INI_DIR/conf.d/10-php.ini
COPY --link frankenphp/Caddyfile /etc/caddy/Caddyfile
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN \
    # Install OS packages
    apt-get update; \
    apt-get -y --no-install-recommends install \
        libnss3-tools \
        unzip \
        supervisor \
    ; \
    # Configure OS
    chmod +x /usr/local/bin/composer; \
    sed -i '/\[supervisord\]/a user=root' /etc/supervisor/supervisord.conf; \
    sed -i '/\[supervisord\]/a nodaemon=true' /etc/supervisor/supervisord.conf; \
    # Install PHP extensions
    install-php-extensions \
        apcu \
        bcmath \
        gd \
        intl \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        xsl \
        zip \
    ; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
