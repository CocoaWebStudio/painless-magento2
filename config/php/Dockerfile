FROM php:7.2-fpm-alpine

ARG WEB_USER=www-data
ARG ENVIROMENT=production

ENV PHPIZE_DEPS \
  autoconf \
  cmake \
  file \
  g++ \
  gcc \
  libc-dev \
  pcre-dev \
  make \
  pkgconf \
  re2c \
  # for GD
  freetype-dev \
  libpng-dev  \
  libjpeg-turbo-dev

ENV PHP_REDIS_VERSION 4.2.0

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY php.ini /usr/local/etc/php/php.ini

RUN chown root:root /usr/local/etc/php-fpm.d/zz-docker.conf \
  && chown root:root /usr/local/etc/php/php.ini \
  && addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -S -D -G ${WEB_USER} ${WEB_USER} \
  && apk add --no-cache git \
  # persistent / runtime deps
  && apk add --no-cache --virtual .persistent-deps \
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
  libmcrypt \
  libxslt-dev \
  libwebp-dev \
  openssh-client \
  patch \
  perl \
  shadow \
  ssmtp \
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
  # install redis
  && pecl install -o -f redis \
  && docker-php-ext-enable redis.so  \
  && pecl clear-cache \
  # Set WEB_USER as owner for /var/www
  && chown -R ${WEB_USER}:${WEB_USER} /var/www/ \
  && chmod -R g+w /var/www/ \
  # Create log folders
  && mkdir -p /var/log/php-fpm \
  && touch /var/log/php-fpm/access.log \
  && touch /var/log/php-fpm/error.log \
  && chown -R ${WEB_USER}:${WEB_USER} /var/log/php-fpm \
  && chown -R ${WEB_USER}:${WEB_USER} /sock \
  # Install xdebug
  && if [ "${ENVIROMENT}" = "developer" ]; then \
    apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.7.1 \
    && docker-php-ext-enable xdebug ; \
  fi

USER ${WEB_USER}
