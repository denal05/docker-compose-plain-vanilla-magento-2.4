# docker-compose-plain-vanilla-magento-2.4

Configuration files for a Docker container running plain-vanilla Magento Open Source 2.4

Once you download this repository on your local computer, you can start this docker container by running:

    docker compose up -d --build

To shut it down:

    docker compose down

To check running docker containers:

    docker ps

To troubleshoot, check the docker container logs:

    docker logs m2.4

Prerequisites:  
1. Add information to your /ets/hosts file
1. Generate a self-signed SSL certificate or use the [Let's Encrypt certbot](https://letsencrypt.org/)
1. Create the local directory /var/www/m2.4/pub/

After doing the prerequisites, such as creating the directory /var/www/m2.4, start the docker containers, get inside the m2.4 docker container, run the composer command to fetch the Magento composer project, and then run the command to install Magento via CLI. See section [#installing-magento-in-your-local-docker-container](#installing-magento-in-your-local-docker-container)

## Important Notes

### Notes on /etc/hosts

You must manually add the following lines in your /ets/hosts file:

    # docker-compose-plain-vanilla-magento-2.4
    172.101.0.10	mysql8.local
    172.101.0.40	elasticsearch7.local
    172.101.0.60	redis6.local
    172.101.0.70	m2.4.local

### Notes on Composer

If running the following command

    $ which composer

returns the following output

    /usr/bin/composer

then please remove the composer via apt

    $ sudo apt remove composer

and install it per the instructions on
https://getcomposer.org/download/
which uses the following command to do so:

    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer

Now, when you run

    $ which composer

the result should be:

    /usr/local/bin/composer

### Notes on PHP

The following is a useful tutorial for having multiple PHP versions on your Ubuntu 22.04:
https://techvblogs.com/blog/install-multiple-php-versions-on-ubuntu-22-04

    sudo apt update
    sudo apt upgrade 
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:ondrej/php
    sudo apt update
    sudo apt install php7.4 php7.4-fpm

Add all required PHP extensions listed on
https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/system-requirements.html

    sudo apt install php7.4-xdebug php7.4-bcmath php7.4-ctype php7.4-curl php7.4-xml php7.4-common php7.4-gd php7.4-intl php7.4-json php7.4-xml php7.4-mbstring openssl php7.4-mysql php7.4-soap php7.4-sockets php-sodium php7.4-xsl php7.4-zip
    sudo update-alternatives --config php

Select the desired version, e.g., 7.4 and check:

    $ php -v

It should return:

    PHP 7.4.33 (cli) (built: Sep  2 2023 08:03:46) ( NTS )
    Copyright (c) The PHP Group
    Zend Engine v3.4.0, Copyright (c) Zend Technologies
        with Zend OPcache v7.4.33, Copyright (c), by Zend Technologies
        with Xdebug v3.1.6, Copyright (c) 2002-2022, by Derick Rethans

After you run 'docker compose up -d --build' and check http://m2.4.local you will most likely get a 500 Internal Server Error. If you do, first log into the app container:

    docker exec -it m2.4 bash

and inspect the log file

    vim /var/log/apache2/m2.4_error.log

If you see the following error:

    PHP Fatal error:  Uncaught Error: Call to undefined function xdebug_disable() in /var/www/m2.4/vendor/magento/magento2-functional-testing-framework/src/Magento/FunctionalTestingFramework/_bootstrap.php:73

Stack Overflow has an answer here:
https://magento.stackexchange.com/questions/327971/uncaught-error-call-to-undefined-function-xdebug-disable
and recommends the following:

    Change
    vendor/magento/magento2-functional-testing-framework/src/Magento/FunctionalTestingFramework/_bootstrap.php
    From :-
        if (!(bool)$debugMode && extension_loaded('xdebug')) {
            xdebug_disable();
        }
    To :-
        if (!(bool)$debugMode && extension_loaded('xdebug')) {
            if (function_exists('xdebug_disable')) {
                xdebug_disable();
            }
        }

and visit http://m2.4.local one more time.

According to the devdocs "Quick start on-premises installation"
https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/composer.html?lang=en  
if you get an error that it cannot delete files in the generated/ folder, remember to run the following:

    $ cd /var/www/m2.4/
    $ sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} +
    $ sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod u+w {} +
    $ sudo chmod u+x bin/magento

Also, run:

    $ cd /var/www/m2.4/
    $ sudo chown -R $USER:www-data .
    $ sudo chmod -R g+rw .

### Notes on Apache

You must manually create a self-signed SSL certificate for Apache in a local environment, or use [Let's Encrypt - ](https://letsencrypt.org/) to generate a valid 3-month SSL certificate for a public website.  

Follow this tutorial to create an SSL certificate for your Magento web server:  
[https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-apache-for-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-create-a-ssl-certificate-on-apache-for-ubuntu-14-04)    

    $ sudo mkdir /etc/apache2/ssl
    $ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

The `ubuntu20.04-apache2.4-mysql8.0.30-php7.4.30-m2.4/m2.4.conf` file is already configured for SSL, and the `ubuntu20.04-apache2.4-mysql8.0.30-php7.4.30-m2.4/entrypoint.sh` file already loads the `ssl` Apache module.


### Notes on database errors

After refactoring 'm2.4' throughout its docker directory and its magento root directory /var/www/m2.4 and upon running

    # bin/magento setup:upgrade

I got the following error:

    ...
    SQLSTATE[HY000]: General error: 1419 You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable), query was: CREATE TRIGGER trg_catalog_category_product_after_insert AFTER INSERT ON catalog_category_product FOR EACH ROW
    BEGIN
    INSERT IGNORE INTO `catalogrule_product_cl` (`entity_id`) VALUES (NEW.`product_id`);
    END

The fix was to log in to MySQL as root and run the following command:

    > set global log_bin_trust_function_creators=1;

Thanks to https://magento.stackexchange.com/a/144715

### Notes on Xdebug

You can follow these videos from Mark Shust to set up Xdebug in PhpStorm and Google Chrome:  
[Install the Xdebug helper browser plugin for Chrome & PhpStorm](https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064478?_gl=1*9pfles*_gcl_au*MzY0MjAzNTEyLjE3MDYwMDg4NjI.)  
[Configure PhpStorm for Xdebug connections](https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064615?_gl=1*utig5f*_gcl_au*MzY0MjAzNTEyLjE3MDYwMDg4NjI.)  
[Trigger an Xdebug breakpoint in PhpStorm](https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064617?_gl=1*utig5f*_gcl_au*MzY0MjAzNTEyLjE3MDYwMDg4NjI.)  
[Trigger an Xdebug breakpoint for CLI commands in PhpStorm](https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36677538?_gl=1*1qvijkx*_gcl_au*MzY0MjAzNTEyLjE3MDYwMDg4NjI.)   
 
### Notes on CLI tools for backup and restore  

Copy from one computer to another:

    scp username@my.production.server:/path/on/server/to/backup_magento.tar.gz /path/on/my/local/computer
    scp /path/on/my/local/computer username@my.production.server:/path/on/server/to/backup_magento.tar.gz

Or even better, use rsync to automatically pick up where it left off after losing connection:

    rsync -avz -P -e ssh username@my.production.server:/path/on/server/to/backup/_var_www_html__xclude-git-log__2024-01-22T16-44CET.zip /path/on/my/local/computer
    rsync -avz -P -e ssh /path/on/my/local/computer username@my.production.server:/path/on/server/to/backup/_var_www_html__xclude-git-log__2024-01-22T16-44CET.zip
    
Archive a directory for backup:

    zip -r /path/on/server/to/backup/_var_www_html__xclude-git-log__2024-01-22T16-44CET.zip /var/www/html/ -x *.git* -x *.log
    
Take a snapshot of the database as a flat SQL file for backup:

    mysqldump -h <hostname> -u<username> -p<password> --databases <db_name> | gzip -9 > /path/on/server/to/backup/db_name__2024-01-22T16-55CET.sql.gz
    
Find out the disk usage of files and directories under a parent directory, filtered by Gigabytes:

    du -h /var/www/html | grep [0-9]G > /path/on/server/to/stats/du/du_-h_var_www_html_PIPE_grep_\[0-9\]G__2024-01-22T16-31CET.txt
    
Find out the general disk space on a computer:

    df -h


### Other Tutorials    

https://www.mageplaza.com/kb/setup-magento-2-on-docker.html  


## Installing Magento in your local docker container

    $ cd ~/projects/docker-compose-plain-vanilla-magento-2.4 
    $ docker compose up -d --build  

    $ docker exec -it m2.4 bash
    # mysql -h mysql8 -uroot -proot
    > create database magento;
    > create user 'magento'@'%' identified by '<SEE ['db'['connection'['default'['password']]]] IN app/etc/env.php>';
    > grant all privileges on magento.* to 'magento'@'%';
    > flush privileges;
    > exit;

Optionally, import a database backup if you have one:

    # mysql -h mysql8 -uroot -proot
    > use magento;
    > source magento.sql;
      OR
    # mysql -uroot -proot magento < /var/www/m2.4/backups/magento.sql

Now, to install Magento:

    $ docker exec -it m2.4 bash
    # cd /var/www/m2.4
    # composer install

According to the official [Installation Guide - Quick Start On-premises Installation](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/composer.html?lang=en), the following commands are required to install Magento Open Source:

    $ cd /var/www/m2.4/
    $ composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.7 /var/www/m2.4/

Set file permissions (you may need to prepend `sudo`):

    $ cd /var/www/m2.4/
    $ find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    $ find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    $ chown -R :www-data .
    $ chmod -R g+rw .
    $ chmod u+x bin/magento

Install the Magento Open Source application:

    $ bin/magento setup:install \
      --base-url=http://m2.4.local \
      --db-host=mysql8.local \
      --db-name=magento \
      --db-user=magento \
      --db-password=magento \
      --admin-firstname=admin \
      --admin-lastname=admin \
      --admin-email=admin@admin.com \
      --admin-user=admin \
      --admin-password=admin123 \
      --language=en_US \
      --currency=USD \
      --timezone=America/Chicago \
      --use-rewrites=1 \
      --search-engine=opensearch \
      --opensearch-host=elasticsearch7.local \
      --opensearch-port=9200 \
      --opensearch-index-prefix=magento2 \
      --opensearch-timeout=15
      
Optionally, change the base_url in the core_config_data table if importing an existing database backup, and don't forget the trailing slash in the URL:

    $ docker exec -it m2.4 bash
    # mysql -h mysql8 -uroot -proot
    > use magento;
    > select * from core_config_data where path like "%base_url%";
    > update core_config_data set value="https://m2.4.local/" where path like "%base_url%";

Optionally, create a database backup:

    $ docker exec -it m2.4 bash
    # mysqldump -h mysql8 -uroot -proot magento | gzip -9 > /var/www/m2.4/backups/magento_db_2023-11-13T14-50CET.sql.gz

