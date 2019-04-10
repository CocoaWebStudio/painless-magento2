FROM certbot/certbot

ENV WEB_USER=www-data

ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

RUN mkdir -p /home/${WEB_USER} \
  && addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -h /home/${WEB_USER} -S -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /home/${WEB_USER}/html

WORKDIR /home/${WEB_USER}/html

RUN chown -R ${WEB_USER}:${WEB_USER} .

CMD certbot certonly --webroot --webroot-path=/home/${WEB_USER}/html --email ${ADMIN_EMAIL} --agree-tos --no-eff-email --staging -d ${HOSTNAME}
