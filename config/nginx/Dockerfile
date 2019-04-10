FROM nginx:alpine

ARG WEB_USER=www-data

RUN mkdir -p /home/${WEB_USER} \
  && addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -h /home/${WEB_USER} -S -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /home/${WEB_USER}/html \
  && mkdir -p /sock \
  && touch /sock/docker.sock \
  && chown -R ${WEB_USER}:${WEB_USER} /sock

WORKDIR /home/${WEB_USER}/html

RUN chown -R ${WEB_USER}:${WEB_USER} .
