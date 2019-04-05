FROM php:7.2-fpm-alpine

ARG WEB_USER=www-data
ARG ENVIROMENT=production

RUN addgroup -g 3000 -S ${WEB_USER}
RUN adduser -u 3000 -S -D -G ${WEB_USER} ${WEB_USER}

ENV PHPIZE_DEPS \
  autoconf \
  cmake \
  file \
  g++ \
  gcc \
  libc-dev \
  pcre-dev \
  make \
  git \
  pkgconf \
  re2c \
  # for GD
  freetype-dev \
  libpng-dev  \
  libjpeg-turbo-dev

ENV RABBITMQ_VERSION v0.9.0

ENV PHP_REDIS_VERSION 4.2.0

# persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
  automake \
  # for intl extension
  icu-dev \
  icu-libs \
  # for soap
  libxml2-dev \
  libxml2-utils \
  # for amqp
  libressl-dev \
  # for GD
  freetype \
  libpng \
  libjpeg-turbo \
  libzip-dev \
  zip \
  zlib-dev \
  rabbitmq-c-dev \
  libmcrypt \
  libxslt-dev \
  libwebp-dev \
  openssh-client \
  patch \
  perl \
  shadow \
  ssmtp \
# workaround for rabbitmq linking issue
  && set -xe && ln -s /usr/lib /usr/local/lib64 \
  && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
  && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-configure bcmath --enable-bcmath \
  && docker-php-ext-configure intl --enable-intl \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-configure mysqli --with-mysqli \
  && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
  && docker-php-ext-configure mbstring --enable-mbstring \
  && docker-php-ext-configure soap --enable-soap \
  && docker-php-ext-install -j$(nproc) \
    gd \
    bcmath \
    intl \
    pcntl \
    mysqli \
    pdo_mysql \
    mbstring \
    soap \
    iconv \
    xsl \
    zip \
  && git clone --branch ${RABBITMQ_VERSION} https://github.com/alanxz/rabbitmq-c.git /tmp/rabbitmq \
  && cd /tmp/rabbitmq \
  && mkdir build && cd build \
  && cmake .. \
  && cmake --build . --target install \
  && git clone --branch ${PHP_REDIS_VERSION} https://github.com/phpredis/phpredis /tmp/phpredis \
  && cd /tmp/phpredis \
  && phpize  \
  && ./configure  \
  && make  \
  && make install \
  && make test \
  && apk del .build-deps

# Set WEB_USER as owner for /var/www
RUN chown -R ${WEB_USER}:${WEB_USER} /var/www/
RUN chmod -R g+w /var/www/

# Create log folders
RUN mkdir -p /var/log/php-fpm && \
  touch /var/log/php-fpm/access.log && \
  touch /var/log/php-fpm/error.log && \
  chown -R ${WEB_USER}:${WEB_USER} /var/log/php-fpm

# Install xdebug
RUN if [ "${ENVIROMENT}" = "development" ] ; \
  then cd /tmp/ && git clone https://github.com/xdebug/xdebug.git \
  && cd xdebug && phpize && ./configure --enable-xdebug && make \
  && mkdir -p /usr/lib/php7/ && cp modules/xdebug.so /usr/lib/php7/xdebug.so \
  && touch /usr/local/etc/php/ext-xdebug.ini \
  && rm -r /tmp/xdebug ; \
  fi