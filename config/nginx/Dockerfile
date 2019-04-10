FROM nginx:alpine

ARG U_ID=33
ARG WEB_USER=www-data

RUN addgroup -g $U_ID ${WEB_USER} \
  && adduser -u $U_ID -D -G ${WEB_USER} ${WEB_USER} \
  && mkdir -p /sock \
  && touch /sock/docker.sock \
  && chown -R ${WEB_USER}:${WEB_USER} /sock
