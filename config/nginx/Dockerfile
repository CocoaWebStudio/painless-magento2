FROM nginx:alpine

ARG UID=33
ARG WEB_USER=www-data

RUN addgroup -g $UID ${WEB_USER} \
  && adduser -u $UID -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /sock \
  && touch /sock/docker.sock \
  && chown -R ${WEB_USER}:${WEB_USER} /sock
