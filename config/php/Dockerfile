FROM php:7.2-fpm-alpine

ARG U_ID=33
ARG WEB_USER=www-data
ARG ENVIROMENT=production
ARG MAGE_DOMAIN=magedocker.test
ARG SMTP_SERVER=smtp.mailtrap.io
ARG SMTP_PORT=2525
ARG SMTP_USER=Your_User
ARG SMTP_PASS=Your_Password

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY php.ini /usr/local/etc/php/php.ini

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

RUN mkdir /etc/ssmtp \
  # email sender configuration
  && echo "root=${EMAIL_SENDER}" > /etc/ssmtp/ssmtp.conf \
  && echo "mailhub=${SMTP_SERVER}:${SMTP_PORT}" >> /etc/ssmtp/ssmtp.conf \
  && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
  && echo "AuthUser=${SMTP_USER}" >> /etc/ssmtp/ssmtp.conf \
  && echo "AuthPass=${SMTP_PASS}" >> /etc/ssmtp/ssmtp.conf \
  # permissions
  && chown root:root /usr/local/etc/php-fpm.d/zz-docker.conf \
  /usr/local/etc/php/php.ini \
  /etc/ssmtp/ssmtp.conf \
  && addgroup -g $U_ID -S ${WEB_USER} \
  && adduser -u $U_ID -h /home/${WEB_USER} -S -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /home/${WEB_USER}/html \
  #configure nginx - fpm socket and log
  && mkdir -p /sock \
  && touch /sock/docker.sock \
  && mkdir -p /var/log/php-fpm \
  && touch /var/log/php-fpm/access.log \
  && touch /var/log/php-fpm/error.log \
  && chown -R ${WEB_USER}:${WEB_USER} /sock \
  /var/log/php-fpm \
  # install persistent deps
  && apk add --no-cache --virtual .persistent-deps \
  automake \
  bash \
  # for intl extension
  icu-dev \
  icu-libs \
  # for GD
  freetype \
  libpng  \
  libjpeg-turbo \
  # for soap
  libxml2-dev \
  libxml2-utils \
  libzip-dev \
  libmcrypt \
  libxslt-dev \
  libwebp-dev \
  patch \
  perl \
  shadow \
  # email
  ssmtp \
  openssl-dev \
  pkgconfig \
  libressl-dev \
  # install build deps
  && apk add --no-cache --virtual .build-deps \
  $PHPIZE_DEPS \
  # php extensions
  # the extensions: ctype, curl, dom, hash, iconv, mbstring, openssl, simplexml, spl, libxml
  # required by magento are already installed
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
  bcmath \
  gd \
  intl \
  opcache \
  pdo_mysql \
  soap \
  xsl \
  zip \
  # install redis
  && pecl install -o -f redis \
  && docker-php-ext-enable redis.so  \
  && pecl clear-cache \
  # Install xdebug
  && if [ "${ENVIROMENT}" = "developer" ]; then \
  apk add --no-cache $PHPIZE_DEPS \
  && pecl install xdebug-2.7.1 \
  && docker-php-ext-enable xdebug ; \
  fi

WORKDIR /home/${WEB_USER}/html

USER ${WEB_USER}
