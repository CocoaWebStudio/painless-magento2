# Painless Magento 2

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)



A dockerized magento 2 community environment ready for development or production.

It's inspired from [dockerize-magento2](https://github.com/arvatoSCM/dockerize-magento2)

## Advantages

  1)  All containers run on Alpine Linux. As a result, the images are smaller, faster and all the containers work with the same rules.
  2) Magento is totally independant from `Painless Magento 2`. Magento lives inside the `src` directory. This is a volume in the `php` container, so you can use `Painless Magento 2` to develop stores, websites or Magento extensions. After, you can use the same system for production or take your code from the source directory to use as you need. 
  3) Composer runs out the containers. Composer is left outside on purpose to keep the containers small and facilitate their use. You always have access to the code in the volume `src`. You should use Composer in the host machine. You can apply your changes without stoping the containers. To run compose commands, go to `src` directory. 
  
     ex: install Fooman Goolge Analytics.
     ```bash
      cd src
      composer require fooman/googleanalyticsplus-m2
      cd ..
      bin/console mage setup:upgrade
     ```
  4) It includes, alpine latest, php 7,2 , nginx run by socket, mariadb, redis, opcache and let's encrypt; xdebug is only install when the enviroment is set in `.env` file as developer.

## Software Requirements

For Linux users you must have a recent version of [docker](https://github.com/docker/docker/releases) and [docker-compose](https://github.com/docker/compose/releases) installed.

If you are a Mac or Windows user, use the [Docker Toolbox](https://www.docker.com/products/docker-toolbox).

You need to have `php` and `composer` installed on your host machine.

## Installation
The instalation process is the same for development, staging or production. The difference is in the information you use to fill the `.env` file. 

To start, use `.env.sample` to create this file.

```bash
  cp .evn.sample .env 
```
Open the file and fill each variable. Each variable has values by default, you can use them as it for development but please change all for your installation in production.

  - ### Old Magento 2 projects:

    -  take a backup from your data base.
    -  Add your existing Magento 2 code inide the `src` directory.
    -  In the root directory of this project run the installer. 

       ```bash
       bin/console install
       ```
    -  When the instalation is done, connect with the phpadmin you just install and use your data base backup for apply your last version. 
    
       -  If you prefer, you can connect by ssh with the mariadb container and apply your backup using mysqldump, you should add your backup in the directory `config/backups` it will appears inside container at the address `/backups`
    -  Done, you can start to use or develop magento 2
  
  - ### Magento 2 from scratch

    -  In the root directory of this projet, run this line:

       ```bash
        rm src/.gitkeep && composer create-project --repository=https://repo.magento.com/ magento/project-community-edition src && touch src/.gitkeep
       ```
       The first time it will ask for your magento authentication keys, [click here](https://devdocs.magento.com/guides/v2.3/install-gde/prereq/connect-auth.html) for obtain yours if you don't have ones.
    -  In the root directory of this project run the installer. 

       ```bash
       bin/console install
       ```
    -  Done, you can start to use or develop magento 2

## Usage

`Painless Magento 2` comes with `bin/console` script that can be used to install Magento and to execute Magentos' bin/magento script inside the PHP docker container:

Trigger the Magento 2 installation process:

```bash
bin/console install
```

Start the docker containers:

```bash
bin/console start
```

Stop the docker containers:

```bash
bin/console stop
```

Execute `bin/magento` inside the docker container:

```bash
bin/console mage [arguments]
```

For more information on how to use docker-compose visit: https://docs.docker.com/compose/

## Configuration

The `install` action depends on some parameters such as usernames and passwords. We have put in some default values for you that will work for a quick test:

```
MAGE_DOMAIN=painlessmagento.test

# use the uid of the host owner of /src directory
U_ID=33
WEB_USER=www-data

# first 3 parts of ip network you like to use
NETWORK_BASE=169.254.81
# magento accepts this enviroments: default, developer or production
ENVIROMENT=developer

DATABASE_NAME=magedocker
DATABASE_USER=magento
DATABASE_PASSWORD=magedocker
DATABASE_ROOT_PASSWORD=magedocker_root
ORDER_PREFIX=inv

ADMIN_USERNAME=admin
ADMIN_FIRSTNAME=Jhon
ADMIN_LASTNAME=Doe
ADMIN_EMAIL=johndoe@example.com
ADMIN_PASSWORD=Magento

DEFAULT_LANGUAGE=en_US
DEFAULT_CURRENCY=USD
DEFAULT_TIMEZONE=America/New_York

BACKEND_FRONTNAME=management
PHPADMIN_PORT=8080

# patch for use volumes, outsite c:/Users,
# 1) add the project's directory to the shared directories in your VM.
# 2) write here the address you add inside the VM
ROOT_PROJECT=/absolute/path/to/your/projet

EMAIL_SENDER=sales@painlessmagento.test
SMTP_SERVER=smtp.mailtrap.io
SMTP_PORT=587
SMTP_USER=Your_User
SMTP_PASS=Your_Password
```

If you want to use different parameters change the values in the [.env](.env) file to your needs.

After customizing the parameters just run trigger the installation with 
```bash
bin/console install
```

## Licensing

Painless Magento 2 is licensed under the Apache License, Version 2.0.
See [LICENSE](LICENSE) for the full license text.

## References and Lectures

starting point and base of this project: 

https://github.com/arvatoSCM/dockerize-magento2


use docker in windows home: 

https://medium.freecodecamp.org/how-to-set-up-docker-and-windows-subsystem-for-linux-a-love-story-35c856968991


docker-compose file reference: 

https://docs.docker.com/compose/compose-file/


Handling permissions with docker volumes: 

https://denibertovic.com/posts/handling-permissions-with-docker-volumes/


docker nginx, let's encrypt configuration: 

https://www.digitalocean.com/community/tutorials/how-to-secure-a-containerized-node-js-application-with-nginx-let-s-encrypt-and-docker-compose


Add users in alpine linux: 

https://stackoverflow.com/questions/49955097/how-do-i-add-a-user-when-im-using-alpine-as-a-base-image


Redis configuration: 

https://devdocs.magento.com/guides/v2.3/config-guide/redis/redis-session.html

https://devdocs.magento.com/guides/v2.3/config-guide/redis/redis-pg-cache.html


magento cli instalation guide:

https://devdocs.magento.com/guides/v2.3/install-gde/install/cli/install-cli-install.html#instgde-install-cli-magento


set cronjob in bash file: 

https://www.digitalocean.com/community/tutorials/how-to-secure-a-containerized-node-js-application-with-nginx-let-s-encrypt-and-docker-compose


