#!/bin/sh
#
# A proxy script that executes bin/magento inside
# the PHP docker container.

# SCRIPTNAME contains the name
# of the current script (e.g. "server")
SCRIPTNAME="bin/$(basename $0)"


# CONFIGFOLDER contains the path
# to the config folder.
CONFIGFOLDER="$(pwd)/config"

# SSLCERTIFICATEFOLDER contains the path
# to the SSL certificate folder that is used by Nginx.
SSLCERTIFICATEFOLDER="$CONFIGFOLDER/nginx/ssl"

# ENVIRONMENTVARIABLESFILE contains the path
# to the file that holds the required environment
# variables for this script.
ENVIRONMENTVARIABLESFILE="$(pwd)/.env"
if [ ! -f $ENVIRONMENTVARIABLESFILE ]; then
  echo >&2 "The file that holds the environment variables was not found at $ENVIRONMENTVARIABLESFILE"
  exit 1
fi

# DOCKERCOMPOSEFILE contains the path
# to the docker-compose.yml file
DOCKERCOMPOSEFILE="$(pwd)/docker-compose.yml"
if [ ! -f $DOCKERCOMPOSEFILE ]; then
  echo >&2 "The docker-compose file was not found at $DOCKERCOMPOSEFILE"
  exit 1
fi

# execute the file that sets the environment variables
. $ENVIRONMENTVARIABLESFILE

if [ -z "$ROOT_PROJECT" ]; then
  ROOT_PROJECT=$(pwd)
fi

if [ -z "$DATABASE_NAME" ]; then
  echo >&2 "The DATABASE_NAME variable is not set"
  exit 1
fi

if [ -z "$DATABASE_USER" ]; then
  echo >&2 "The DATABASE_USER variable is not set"
  exit 1
fi

if [ -z "$DATABASE_PASSWORD" ]; then
  echo >&2 "The DATABASE_PASSWORD variable is not set"
  exit 1
fi

if [ -z "$DATABASE_ROOT_PASSWORD" ]; then
  echo >&2 "The DATABASE_ROOT_PASSWORD variable is not set"
  exit 1
fi

if [ -z "$ADMIN_USERNAME" ]; then
  echo >&2 "The ADMIN_USERNAME variable is not set"
  exit 1
fi

if [ -z "$ADMIN_FIRSTNAME" ]; then
  echo >&2 "The ADMIN_FIRSTNAME variable is not set"
  exit 1
fi

if [ -z "$ADMIN_LASTNAME" ]; then
  echo >&2 "The ADMIN_LASTNAME variable is not set"
  exit 1
fi

if [ -z "$ADMIN_EMAIL" ]; then
  echo >&2 "The ADMIN_EMAIL variable is not set"
  exit 1
fi

if [ -z "$ADMIN_PASSWORD" ]; then
  echo >&2 "The ADMIN_PASSWORD variable is not set"
  exit 1
fi

if [ -z "$DEFAULT_LANGUAGE" ]; then
  echo >&2 "The DEFAULT_LANGUAGE variable is not set"
  exit 1
fi

if [ -z "$DEFAULT_CURRENCY" ]; then
  echo >&2 "The DEFAULT_CURRENCY variable is not set"
  exit 1
fi

if [ -z "$DEFAULT_TIMEZONE" ]; then
  echo >&2 "The DEFAULT_TIMEZONE variable is not set"
  exit 1
fi

if [ -z "$BACKEND_FRONTNAME" ]; then
  echo >&2 "The BACKEND_FRONTNAME variable is not set"
  exit 1
fi

# Check availability of docker
hash docker 2>/dev/null || {
  echo >&2 "$SCRIPTNAME requires \"docker\""
  exit 1
}

# Check availability of docker-compose
hash docker-compose 2>/dev/null || {
  echo >&2 "$SCRIPTNAME requires \"docker-compose\""
  exit 1
}

#######################################
# Execute bin/magento inside the php docker
# container with all given arguments.
# Globals:
#   None
# Arguments:
#   *
# Returns:
#   None
#######################################
executeInMagento() {
  if [ $(isRunning) = false ]; then
    echo >&2 "Docker is not running. Please start the containers first."
    exit 1
  fi

  # pass the arguments to the bin/magento script inside the PHP container
  docker-compose exec -u ${WEB_USER} php sh -c "bin/magento $*"
}

generateLocalSSL() {
  # assemble file paths for key and cert
  SSLKEYFILEPATH="$SSLCERTIFICATEFOLDER/key.pem"
  SSLCERTFILEPATH="$SSLCERTIFICATEFOLDER/cert.pem"

  # check if the certificates already exist
  if [ -f "$SSLKEYFILEPATH" ] && [ -f "$SSLCERTFILEPATH" ]; then
    echo "Using existing SSL certificates for $MAGE_DOMAIN:"
    printf "  %-8s%-30s\n" "Key:" $SSLKEYFILEPATH
    printf "  %-8s%-30s\n" "Cert:" $SSLCERTFILEPATH
    return 0
  fi

  # Check availability of openssl
  hash openssl 2>/dev/null || {
    echo >&2 "$SCRIPTNAME requires \"openssl\" to generate SSL certificates."
    echo >&2 "Please install openssl or place the SSL certificate and key manually into the certificate-folder \"$SSLCERTIFICATEFOLDER\":"
    printf >&2 "  %-8s%-30s\n" "Key:" $SSLKEYFILEPATH
    printf >&2 "  %-8s%-30s\n" "Cert:" $SSLCERTFILEPATH
    return 1
  }

  openssl req -x509 -newkey rsa:2048 -nodes -subj "/CN=$MAGE_DOMAIN" -keyout $SSLKEYFILEPATH -out $SSLCERTFILEPATH -days 360 2>/dev/null
  if [ $? -ne 0 ]; then
    echo >&2 "Generating SSL certificates failed."
    echo >&2 "Please place the key and certificate into the certificate-folder \"$SSLCERTIFICATEFOLDER\":"
    printf >&2 "  %-8s%-30s\n" "Key:" $SSLKEYFILEPATH
    printf >&2 "  %-8s%-30s\n" "Cert:" $SSLCERTFILEPATH

    return 1
  fi

  echo "Generated new SSL certificates for $MAGE_DOMAIN:"
  printf "  %-8s%-30s\n" "Key:" $SSLKEYFILEPATH
  printf "  %-8s%-30s\n" "Cert:" $SSLCERTFILEPATH
  return 0
}

generateDHparam() {
  # assemble file paths for key and cert
  DHFILEPATH="$CONFIGFOLDER/dhparam/dhparam-2048.pem"

  # check if the certificates already exist
  if [ -f "$DHFILEPATH" ]; then
    echo "Using existing Diffie-Hellman key for $MAGE_DOMAIN:"
    printf "  %-8s%-30s\n" "Key:" $DHFILEPATH
    return 0
  fi

  # Check availability of openssl
  hash openssl 2>/dev/null || {
    echo >&2 "$SCRIPTNAME requires \"openssl\" to generate Diffie-Hellman key."
    echo >&2 "Please install openssl or place the Diffie-Hellman key folder \"$SSLCERTIFICATEFOLDER\":"
    printf >&2 "  %-8s%-30s\n" "Key:" $DHFILEPATH
    return 0
  }

  openssl dhparam -out $DHFILEPATH 2048
  if [ $? -ne 0 ]; then
    echo >&2 "Generating Diffie-Hellman key failed."
    return 1
  fi

  echo "New Diffie-Hellman key for $MAGE_DOMAIN was generated"
  return 0
}

applyCertificates() {
  if [ $ENVIROMENT = 'production' ]; then
    ROOT_PROJECT=$ROOT_PROJECT docker-compose stop certbot
    ROOT_PROJECT=$ROOT_PROJECT docker-compose up -d --no-deps --remove-orphans --build certbot

    generateDHparam

    sed "s|\$MAGE_DOMAIN|$MAGE_DOMAIN|g; s|\$WEB_USER|$WEB_USER|g" "$CONFIGFOLDER/nginx/templates/sites-enabled/prod.conf.template" >"$CONFIGFOLDER/nginx/sites-enabled/default.conf"
  else
    generateLocalSSL
    if [ $? -ne 0 ]; then
      exit 1
    fi
    sed "s|\$MAGE_DOMAIN|$MAGE_DOMAIN|g; s|\$WEB_USER|$WEB_USER|g" "$CONFIGFOLDER/nginx/templates/sites-enabled/dev.conf.template" >"$CONFIGFOLDER/nginx/sites-enabled/default.conf"
  fi

  ROOT_PROJECT=$ROOT_PROJECT docker-compose stop web
  ROOT_PROJECT=$ROOT_PROJECT docker-compose up -d --no-deps --remove-orphans --build web

  executeInMagento setup:store-config:set \
    --base-url-secure="https://${MAGE_DOMAIN}/" \
    --base-url="https://${MAGE_DOMAIN}/"

  executeInMagento cache:flush

  # Set a cronjob for auto-renew certificates
  sed "s|\$(pwd)|$(pwd)|g" \
    "$CONFIGFOLDER/certbot/ssl_renew.sh.template" \
    >"$CONFIGFOLDER/certbot/ssl_renew.sh"

  chmod +x $CONFIGFOLDER/certbot/ssl_renew.sh

  echo "0 3 1 * * $CONFIGFOLDER/certbot/ssl_renew.sh >/dev/null 2>&1" >>mycron
  crontab mycron
  rm mycron

  echo "Done, pleaase test https://$MAGE_DOMAIN"
  return 0
}

installMagento() {
  echo "Delete config before install"
  rm -f src/app/etc/env.php

  echo "Remove old genereted code"
  rm -Rf src/generated/code/Magento

  # Install magento 2
  echo "Install magento 2"

  baseURLInsecure="http://${MAGE_DOMAIN}/"

  executeInMagento setup:install \
    --cleanup-database \
    --base-url=${baseURLInsecure} \
    --use-secure=0 \
    --use-secure-admin=0 \
    --backend-frontname=${BACKEND_FRONTNAME} \
    --language=${DEFAULT_LANGUAGE} \
    --currency=${DEFAULT_CURRENCY} \
    --timezone=${DEFAULT_TIMEZONE} \
    --db-host=mysql \
    --db-name=${DATABASE_NAME} \
    --db-user=${DATABASE_USER} \
    --db-password=${DATABASE_PASSWORD} \
    --admin-firstname=${ADMIN_FIRSTNAME} \
    --admin-lastname=${ADMIN_LASTNAME} \
    --admin-email=${ADMIN_EMAIL} \
    --admin-user=${ADMIN_USERNAME} \
    --admin-password=${ADMIN_PASSWORD} \
    --sales-order-increment-prefix=${ORDER_PREFIX} \
    --session-save=redis \
    --session-save-redis-host=${NETWORK_BASE}.7 \
    --session-save-redis-db=2 \
    --cache-backend=redis \
    --cache-backend-redis-server=${NETWORK_BASE}.7 \
    --cache-backend-redis-db=0

  echo "Install and update modules"
  executeInMagento setup:upgrade

  echo "Set enviroment"
  executeInMagento deploy:mode:set ${ENVIROMENT}

  echo "Compile the code"
  executeInMagento setup:di:compile

  # Deploy static content
  executeInMagento setup:static-content:deploy -f

  # Index data
  executeInMagento indexer:reindex
}

#######################################
# Create all configuration files, create the containers and install magento
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
build() {
  case "$2" in
    mage1)
      sed "s|\$MAGE_DOMAIN|$MAGE_DOMAIN|g; s|\$WEB_USER|$WEB_USER|g; s|\$PUBLIC_DIR|$PUBLIC_DIR|g" "$CONFIGFOLDER/nginx/templates/sites-enabled/unsecureMage1.conf.template" >"$CONFIGFOLDER/nginx/sites-enabled/default.conf"
      ;;
    *)
    sed "s|\$MAGE_DOMAIN|$MAGE_DOMAIN|g; s|\$WEB_USER|$WEB_USER|g" "$CONFIGFOLDER/nginx/templates/sites-enabled/unsecure.conf.template" >"$CONFIGFOLDER/nginx/sites-enabled/default.conf"
    ;;
  esac

  sed "s|\$WEB_USER|$WEB_USER|g" "$CONFIGFOLDER/nginx/templates/nginx.conf.template" >"$CONFIGFOLDER/nginx/nginx.conf"
  sed "s|\$WEB_USER|$WEB_USER|g" "$CONFIGFOLDER/php/zz-docker.conf.template" >"$CONFIGFOLDER/php/zz-docker.conf"

  stop
  ROOT_PROJECT=$ROOT_PROJECT docker-compose -f ${DOCKERCOMPOSEFILE} up -d --build

  # Print results
  echo "All containers created"
}

#######################################
# Create all configuration files, create the containers, install magento and add the ssl certificates
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
Totalinstallation() {
  build

  # wait for MySQL to come up
  sleep 30

  installMagento

  echo "Adding SSL certification"
  applyCertificates

  # Print results
  echo "the enviroment is ${ENVIROMENT}"
  echo "Installation complete."
  printf "%-15s%-30s\n" "Frontend" ${baseURLInsecure}
  printf "%-15s%-30s\n" "Backend" "//${MAGE_DOMAIN}/${BACKEND_FRONTNAME}"
  printf "%-15s%s: %s\n" "" "Username" ${ADMIN_USERNAME}
  printf "%-15s%s: %s\n" "" "Password" ${ADMIN_PASSWORD}
}

#######################################
# Print the status of the server
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
status() {
  if [ $(isRunning) = false ]; then
    echo >&2 "Not running"
    exit 1
  fi

  # docker status
  docker ps -q | xargs docker inspect --format='{{ .Name }} {{ .State.Status }}' | sed 's:^/::g' | xargs printf "%-45s%-30s\n"

}

#######################################
# Stop the server
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
stop() {

  if [ $(isRunning) = true ]; then
    # stop all docker containers
    ROOT_PROJECT=$ROOT_PROJECT docker-compose -f $DOCKERCOMPOSEFILE down
  fi

}

#######################################
# Start the server and all of its
# components
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
start() {
  if [ $(isRunning) = true ]; then
    echo >&2 "The component are already running"
    exit 1
  fi

  # start docker containers
  ROOT_PROJECT=$ROOT_PROJECT docker-compose -f ${DOCKERCOMPOSEFILE} up -d

}

#######################################
# Restart the server and all of its
# components
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
restart() {
  stop
  start
}

#######################################
# Check what containers are running
# Globals:
#   DOCKERCOMPOSEFILE
# Arguments:
#   None
# Returns:
#   true|false
#######################################
isRunning() {
  dockerStatusOutput=$(docker-compose -f $DOCKERCOMPOSEFILE ps -q)
  outputSize=${#dockerStatusOutput}
  if [ "$outputSize" -gt 0 ]; then
    echo true
  else
    echo false
  fi
}

#######################################
# Print the usage information for the
# server control script
# Globals:
#   SCRIPTNAME
# Arguments:
#   None
# Returns:
#   None
#######################################
usage() {
  echo "PAINLESS MAGENTO 2"
  echo "A dockerized environment ready for development or production"
  echo ""
  echo "Important!"
  echo "You need fill the .env file before use this script"
  echo "run"
  echo ""
  echo "    cp .env.sample .env"
  echo ""
  echo "Open the .env file and fill each variable."
  echo ""
  echo "Usage:"
  echo "$SCRIPTNAME <action> <arguments...>"
  echo ""
  echo "Actions:"
  printf "  %-30s%-30s\n" "install" "Installation of nginx, php7.2, mariadb, redis, let's encrypt and ssmtp. "
  printf "  %-30s%-30s\n" "mage <magento:function>" "Execute bin/magento inside docker"
  printf "  %-30s%-30s\n" "start" "Start all containers"
  printf "  %-30s%-30s\n" "rebuilt" "Rebuild containers"
  printf "  %-30s%-30s\n" "restart" "Restart all"
  printf "  %-30s%-30s\n" "stop" "Stop the server"
  printf "  %-30s%-30s\n" "status" "Get the current server status"
  printf "  %-30s%-30s\n" "ssl" "Apply or renew SSL certificates self signed for development or let's encrypt for production"
}

case "$1" in
install)
  shift 1
  Totalinstallation $*
  ;;
mage)
  shift 1
  executeInMagento $*
  ;;
start)
  start
  ;;
restart)
  restart
  ;;
ssl)
  applyCertificates
  ;;
stop)
  stop
  ;;
status)
  status
  ;;
rebuild)
  build $*
  ;;
*)
  usage
  ;;
esac

exit 0
