FROM certbot/certbot

ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

CMD certbot certonly --webroot \
  --webroot-path=/var/www/html \
  --email ${ADMIN_EMAIL} \
  --agree-tos --no-eff-email \
  --staging \
  -d ${HOSTNAME}
