# Dockerfile
FROM debian:12-slim

LABEL maintainer="Frank Moeller <fcm42@protonmail.com>"
LABEL description="GOsa² LDAP Administration Tool with PHP-FPM"
LABEL version="1.0.4"

# environment
ENV DEBIAN_FRONTEND=noninteractive
ENV GOSA_VERSION=2.8.1
ENV PHP_VERSION=8.2

# package installation
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    ca-certificates \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-imap \
    gettext \
    sudo \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# create group and user www-data
RUN groupadd -r www-data 2>/dev/null || true \
    && useradd -r -g www-data www-data 2>/dev/null || true

# download GOsa²
RUN cd /tmp && \
    wget -O gosa.tar.gz "https://github.com/gosa-project/gosa-core/archive/refs/tags/${GOSA_VERSION}.tar.gz" && \
    tar -xzf gosa.tar.gz && \
    mkdir -p /var/www && \
    mv gosa-core-${GOSA_VERSION} /var/www/gosa && \
    chown -R www-data:www-data /var/www/gosa && \
    rm gosa.tar.gz

# create directories
RUN mkdir -p /var/lib/gosa \
    /var/spool/gosa \
    /var/cache/gosa \
    /etc/gosa \
    /run/php \
    /var/log/php \
    && chown -R www-data:www-data /etc/gosa /var/lib/gosa /var/spool/gosa /var/cache/gosa /run/php /var/log/php

# change log dir
RUN sed -i -e "s/^error_log = .*/error_log = \/var\/log\/php\/php8.2-fpm.log/" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf 

# copy configs
COPY config/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/pool.d/gosa.conf
COPY config/gosa.conf /etc/gosa/gosa.conf
COPY config/entrypoint.sh /usr/local/bin/entrypoint.sh

# set permissions
RUN chmod +x /usr/local/bin/entrypoint.sh

# expose port for php-fpm
EXPOSE 9001

# set working dir
WORKDIR /var/www/gosa

# change user (www-data)
USER www-data

# healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/bin/php-fpm${PHP_VERSION} -t || exit 1

# entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2", "--nodaemonize", "--fpm-config", "/etc/php/8.2/fpm/php-fpm.conf"]
