FROM certbot/certbot

ENV ADMIN_EMAIL=johndoe@example.com
ENV HOSTNAME=magedocker.test

CMD certbot certonly --webroot \
  -w /var/www//mage \
  --email ${ADMIN_EMAIL} \
  --agree-tos --no-eff-email \
  --staging \
  -d ${HOSTNAME}
