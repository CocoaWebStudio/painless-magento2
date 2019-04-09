FROM nginx:alpine

ARG WEB_USER=www-data

RUN addgroup -g 3000 -S ${WEB_USER} \
  && adduser -u 3000 -S -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /sock \
  && touch /sock/docker.sock \
  && chown -R ${WEB_USER}:${WEB_USER} /sock

USER ${WEB_USER}
