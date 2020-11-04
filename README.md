# Painless Magento 2 & 1

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A dockerized magento 2 community environment ready for development or production. It supports magento 1.9.x for development

Inspired from [dockerize-magento2](https://github.com/arvatoSCM/dockerize-magento2)

## Advantages

1.  All containers run on Alpine Linux. As a result, the images are smaller, faster and all the containers work with the same rules.
2.  Magento is totally independant from `Painless Magento 2`. Magento lives inside the `src` directory. This is a volume in the `php` container, so you can use `Painless Magento 2` to develop stores, websites or Magento extensions. After, you can use the same system for production or take your code from the source directory to use as you need.
3.  Composer runs out the containers. Composer is left outside on purpose to keep the containers small and facilitate their use. You always have access to the code in the volume `src`. You should use Composer in the host machine. You can apply your changes without stoping the containers. To run compose commands, go to `src` directory.

    ex: install Fooman Goolge Analytics.

    ```bash
     cd src
     composer require fooman/googleanalyticsplus-m2
     cd ..
     sh bin/console.sh mage setup:upgrade
    ```

4.  It includes, alpine latest, php 7,2 , nginx run by socket, mariadb, redis, opcache and let's encrypt; xdebug is only install when the enviroment is set in `.env` file as developer.

## Software Requirements

For Linux users you must have a recent version of [docker](https://github.com/docker/docker/releases) and [docker-compose](https://github.com/docker/compose/releases) installed.

If you are a Mac or Windows user, use [Docker Desktop](https://www.docker.com/products/docker-desktop) or [Docker Toolbox](https://www.docker.com/products/docker-toolbox).

- **Docker Desktop**: nginx container needs the port 80 in your machine, please verify it is free. Many times in windows the problem is the W3SVC service (World Wide Web Publishing Service) , please disable it.

You need to have `php` and `composer` installed on your host machine.

You need to have all `php extensions` required by magento installed on your host machine :

- ext-bcmath

- ext-ctype

- ext-curl

- ext-dom

- ext-gd

- ext-hash

- ext-iconv

- ext-intl

- ext-mbstring

- ext-openssl

- ext-pdo_mysql

- ext-simplexml

- ext-soap

- ext-spl

- ext-xsl

- ext-zip

- lib-libxml

## Installation

The instalation process is the same for development, staging or production. The difference is in the information you use to fill the `.env` file.

To start, use `.env.sample` to create this file.

```bash
  cp .evn.sample .env
```

Open the file and fill each variable. Each variable has values by default, you can use them as it for development but please for your own safety change all for your installation in production.

- ### Old Magento projects:

  - take a backup from your data base.
  - Add your existing Magento 2 code inside the `src` directory.
  - **Magento 2 only**: In the root directory of this project run the installer.

    ```bash
    sh bin/console.sh install
    ```

  - Connect with the phpadmin you just install and use your data base backup for apply your last version. Just use the port you set on `.env` file.

    - If you prefer, you can use [docker-compose exec](https://docs.docker.com/compose/reference/exec/) comand in the mariadb container and apply your backup using mysql, you should add your backup in the directory `config/backups` it will appears inside container at the address `/backups`

    ```bash
      docker-compose exec mysql sh -c="mysql -u $DATABASE_USER -p $DATABASE_NAME < /backups/$BACKUP_FILE_NAME"
    ```

  - Done, you can start to use or develop your old magento project.

- ### Magento 2 from scratch

  - In the root directory of this projet, run this line:

    ```bash
     rm src/.gitkeep && composer create-project --repository=https://repo.magento.com/ magento/project-community-edition src && touch src/.gitkeep
    ```

    The first time it will ask for your magento authentication keys, [click here](https://devdocs.magento.com/guides/v2.3/install-gde/prereq/connect-auth.html) for obtain yours if you don't have ones.

  - In the root directory of this project run the installer.

    ```bash
    sh bin/console.sh install
    ```

  - Done, you can start to use or develop magento 2

## Usage

`Painless Magento 2` comes with `bin/console.sh` script that can be used to install Magento, execute Magento's commands, create config files and manage docker containers:

Trigger the Magento 2 installation process:

```bash
sh bin/console.sh install
```

Start the docker containers:

```bash
sh bin/console.sh start
```

Stop the docker containers:

```bash
sh bin/console.sh stop
```

Execute `bin/magento` inside the docker container:

```bash
sh bin/console.sh mage [arguments]
```

For more information on how to use `docker-compose` visit: https://docs.docker.com/compose/

## Variables

You can customize them in the `.env` file before run the instalation

| Variable               | Default Value              | Notes                                                                                                                                                                                                                                    |
| ---------------------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MAGE_DOMAIN            | painlessmagento.test       |                                                                                                                                                                                                                                          |
| ROOT_PROJECT           | _Commented_                | DOCKER-TOOLS USERS ONLY <br>patch for use volumes, outsite c:/Users in windows,<br> 1) add the project's directory to the shared directories in your VM. <br>2) uncomment ROOT_PROJECT line and write the address you add inside the VM. |
| U_ID                    | 33                         | Use the uid of the host owner of /src directory <br> Using bash or bash for windows you can get this using <br> `echo $UID`                                                                                                              |
| WEB_USER               | www-data                   | Using bash or bash for windows you can get this using <br> `echo $USERNAME`                                                                                                                                                              |
| NETWORK_BASE           | 169.254.81                 | first 3 parts of local ip network you like to use                                                                                                                                                                                        |
| PHPMYADMIN_PORT        | 8080                       | You can access `phpmyadmin` using http://MAGE_DOMAIN:PHPMYADMIN_PORT <br>_TODO: add phpadmin to nginx adding a subdomain and add SSL certification_                                                                                      |
|                        |                            | **MAGENTO VARIABLES**                                                                                                                                                                                                                    |
| ENVIROMENT             | developer                  | Magento accepts this three enviroments: <br> - default <br> - developer <br> - production                                                                                                                                                |
| DATABASE_NAME          | painlessmagento            |
| DATABASE_USER          | magento                    |
| DATABASE_PASSWORD      | magneto123                 |
| DATABASE_ROOT_PASSWORD | magento123_root            |
| ORDER_PREFIX           | inv                        |
| BACKEND_FRONTNAME      | management                 |
| ADMIN_USERNAME         | admin                      |
| ADMIN_FIRSTNAME        | Jhon                       |
| ADMIN_LASTNAME         | Doe                        |
| ADMIN_EMAIL            | johndoe@example.com        |
| ADMIN_PASSWORD         | Magento123                 |
| DEFAULT_LANGUAGE       | en_US                      |
| DEFAULT_CURRENCY       | USD                        |
| DEFAULT_TIMEZONE       | America/New_York           |
| EMAIL_SENDER           | sales@painlessmagento.test |
| SMTP_SERVER            | smtp.mailtrap.io           | I like use [mailtrap](https://mailtrap.io) for development                                                                                                                                                                               |
| SMTP_PORT              | 587                        |
| SMTP_USER              | Your_User                  |
| SMTP_PASS              | Your_Password              |

## Warnigs

**Use at your own risk, no waranties included.**

You can use the default enviroment values for development, it's not big deal but.

**I strongly recomemnd change ALL the values in the [.env](.env) when you use PainlessMagento for production.**

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
