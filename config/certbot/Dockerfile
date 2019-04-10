FROM certbot/certbot

ARG U_ID=33
ENV WEB_USER=www-data
ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

RUN addgroup -g $U_ID -S ${WEB_USER} \
  && adduser -u $U_ID -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /home/${WEB_USER}/html \
  && chown -R ${WEB_USER}:${WEB_USER} /home/${WEB_USER}

CMD certbot certonly --webroot --webroot-path=/home/${WEB_USER}/html --email ${ADMIN_EMAIL} --agree-tos --no-eff-email --staging -d ${HOSTNAME}
