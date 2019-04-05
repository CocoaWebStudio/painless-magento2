FROM nginx:alpine

ARG WEB_USER=www-data

RUN addgroup -g 3000 -S ${WEB_USER}
RUN adduser -u 3000 -S -D -G ${WEB_USER} ${WEB_USER}

RUN mkdir -p /sock
RUN touch /sock/docker.sock
RUN chown -R ${WEB_USER}:${WEB_USER} /sock