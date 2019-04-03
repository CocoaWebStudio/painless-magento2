FROM php:7.2-fpm-alpine

ARG ENVIROMENT=production

# Install Magento requirements
RUN apk add --no-cache \
  autoconf \
  automake \
  freetype-dev \
  libzip-dev \
  rabbitmq-c-dev \
  g++ \
  git \
  icu-dev \
  icu-libs \
  libjpeg-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libxml2-dev \
  libxml2-utils \
  libxslt-dev \
  libwebp-dev \
  make \
  openssh-client \
  patch \
  perl \
  shadow \
  ssmtp

# Run virtual
RUN apk add --no-cache --virtual .build-deps

# configure bcmath
RUN docker-php-ext-configure bcmath && \
  docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-webp-dir=/usr/include 

# Docker install php
RUN docker-php-ext-install \
  bcmath \
  intl \
  gd \
  opcache \
  pdo_mysql \
  soap \
  xsl \
  zip

RUN yes "" | pecl install apcu redis

# install redis
RUN docker-php-ext-enable apcu redis && \
  perl -pi -e "s/mailhub=mail/mailhub=maildev/" /etc/ssmtp/ssmtp.conf && \
  perl -pi -e "s|;pm.status_path = /status|pm.status_path = /php_fpm_status|g" /usr/local/etc/php-fpm.d/www.conf && \
  apk del .build-deps

# Set www-data as owner for /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod -R g+w /var/www/

# Create log folders
RUN mkdir -p /var/log/php-fpm && \
    touch /var/log/php-fpm/access.log && \
    touch /var/log/php-fpm/error.log && \
    chown -R www-data:www-data /var/log/php-fpm

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr \
    && docker-php-ext-install gd

# Install xdebug

RUN echo "${ENVIROMENT}" 

RUN if [ "${ENVIROMENT}" = "development" ] ; \
    then cd /tmp/ && git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug && phpize && ./configure --enable-xdebug && make \
    && mkdir -p /usr/lib/php7/ && cp modules/xdebug.so /usr/lib/php7/xdebug.so \
    && touch /usr/local/etc/php/ext-xdebug.ini \
    && rm -r /tmp/xdebug ; \
    fi