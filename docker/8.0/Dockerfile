# syntax = docker/dockerfile:1.3

# ---
# 1. Use Debian stable (11, bullseye) version of PHP
FROM php:8.0.30-fpm-bullseye AS base

# ---
# 2. Upgrade system and installed dependencies for security patches
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    apt-get update; \
    apt-get upgrade -y

# ---
# 3. Install PHP extensions
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    --mount=type=tmpfs,target=/var/log \
    set -eux; \
    # ---
    # Use `docker-php-ext-install` to ease installation of PHP
    # extensions
    #
    # Ref: https://github.com/mlocati/docker-php-extension-installer
    export \
        PHP_EXT_INSTALLER_VERSION=2.1.35 \
        PHP_EXT_INSTALLER_SHA256SUM=b554624923976160a9104293d798216e56ecc255b2dcb587dabb95bb0e6ad222 \
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
    } | tee "${PHP_INI_DIR}/conf.d/20-opcache.ini"

# ---
# 5. Vapor bootstrap scripts and entrypoint
COPY --chmod=0755 bootstrap bootstrap.php /opt/

ENTRYPOINT []
CMD /opt/bootstrap
