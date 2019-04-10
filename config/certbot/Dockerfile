FROM certbot/certbot

ARG WEB_USER=www-data

ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

RUN addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -S -D -G ${WEB_USER} ${WEB_USER}

CMD certbot certonly --webroot --webroot-path=/var/www/html --email ${ADMIN_EMAIL} --agree-tos --no-eff-email --staging -d ${HOSTNAME}
