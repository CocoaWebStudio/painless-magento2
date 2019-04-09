FROM certbot/certbot

ARG ADMIN_EMAIL=johndoe@example.com
ARG HOSTNAME=magedocker.test

RUN certbot certonly --webroot \
  -w /var/www/html \
  --email ${ADMIN_EMAIL} \
  --agree-tos --no-eff-email \
  --staging \
  -d ${HOSTNAME}
