# syntax = docker/dockerfile:1

ARG PHP_VERSION=8.2.34
ARG BASE_DISTRO=trixie

# ---
# 1. Use Debian (${BASE_DISTRO}) version of PHP
FROM php:${PHP_VERSION}-fpm-${BASE_DISTRO} AS base

# ---
# 2. Upgrade system and installed dependencies for security patches
RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    apt-get update; \
    apt-get upgrade -y

# ---
# 3. Install PHP extensions
RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    # ---
    # Use `docker-php-ext-install` to ease installation of PHP
    # extensions
    #
    # Ref: https://github.com/mlocati/docker-php-extension-installer
    export \
        PHP_EXT_INSTALLER_VERSION=2.12.3 \
        PHP_EXT_INSTALLER_SHA256SUM=9c26dd516b8147235c4e924c52e2f076fb2b3f278f5457e88918518ebfee9e01 \
        IPE_GD_WITHOUTAVIF=1 \
    ; \
    cd /tmp; \
    { \
        curl --fail -Lo install-php-extensions \
            https://github.com/mlocati/docker-php-extension-installer/releases/download/${PHP_EXT_INSTALLER_VERSION}/install-php-extensions; \
        echo "${PHP_EXT_INSTALLER_SHA256SUM} *install-php-extensions" | sha256sum -c - >/dev/null 2>&1; \
        chmod +x install-php-extensions; \
    }; \
    # ---
    # Install common PHP extensions
    #
    # (no need to install mbstring, pdo, tokenizer or xml as they are already part of base image)
    ./install-php-extensions \
        bcmath \
        calendar \
        exif \
        gd \
        intl \
        memcached-stable \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        redis-stable \
        sockets \
        xsl \
        zip \
    ; \
    # opcache already installed, just enable extension
    docker-php-ext-enable opcache; \
    # remove PHP extension installer
    rm -f ./install-php-extensions

# ---
# 4. Tweak both PHP and extensions configuration
RUN set -eux; \
    # ---
    # Configure PHP in production mode
    cp -f "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"; \
    # ---
    # Tweak settings for Vapor
    #
    # Ref: https://github.com/laravel/vapor-php-build/blob/master/php80/runtime/php.ini
    { \
        echo "expose_php=off"; \
        echo "memory_limit=2048M"; \
        echo 'variables_order="EGPCS"'; \
        echo "disable_functions=fastcgi_finish_request"; \
    } | tee "${PHP_INI_DIR}/conf.d/10-vapor.ini"; \
    # ---
    # OPCache tweaks
    { \
        echo "opcache.enable_cli=1"; \
        echo 'opcache.file_cache="/tmp/opcache"'; \
        echo "opcache.validate_timestamps=0"; \
        echo "opcache.memory_consumption=128"; \
        echo "opcache.max_accelerated_files=10000"; \
    } | tee "${PHP_INI_DIR}/conf.d/20-opcache.ini"; \
    # ---
    # Hardening: do not let upload progress write client-supplied names
    # into session files, and refuse session IDs PHP did not create
    #
    # Ref: https://www.php.net/manual/en/session.configuration.php
    { \
        echo "session.upload_progress.enabled=0"; \
        echo "session.use_strict_mode=1"; \
    } | tee "${PHP_INI_DIR}/conf.d/30-hardening.ini"

# ---
# 5. Vapor bootstrap scripts and entrypoint
COPY --chmod=0755 bootstrap bootstrap.php /opt/

ENTRYPOINT []
CMD /opt/bootstrap
