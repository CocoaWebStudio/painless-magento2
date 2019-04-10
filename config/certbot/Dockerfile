FROM certbot/certbot

ARG WEB_USER=www-data

ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

RUN addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -h -S -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /home/${WEB_USER}/html

WORKDIR /home/${WEB_USER}/html

RUN chown -R ${WEB_USER}:${WEB_USER} .

CMD certbot certonly --webroot --webroot-path=/home/${WEB_USER}/html --email ${ADMIN_EMAIL} --agree-tos --no-eff-email --staging -d ${HOSTNAME}
