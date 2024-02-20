# set the base image
FROM ubuntu:20.04

# Host user
ARG USER

#ENV HOME /var/www
ENV DEBIAN_FRONTEND noninteractive

# update sources list
RUN apt-get update

# add repo for php versions and install php
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apache2 \
    apt-utils \
    build-essential \
    ca-certificates \
    cron \
    curl \
    git \
    htop \
    iputils-ping \
    locales \
    mysql-client \
    nano \
    openssh-client \
    openssl \
    php7.4 \
    php7.4-bcmath \
    php7.4-cli \
    php7.4-common \
    php7.4-ctype \
    php7.4-curl \
    php7.4-dev \
    php-directory-scanner \
    php-dompdf \
    php7.4-dom \
    php7.4-fileinfo \
    php7.4-fpm \
    php7.4-gd \
#    php-symfony-password-hasher \
#    php-symfony-polyfill-iconv \
    php-imagick \
    php7.4-intl \
    php7.4-json \
    php7.4-ldap \
    php7.4-mbstring \
    php7.4-mcrypt \
    php7.4-mysql \
    php-pear \
#    php-composer-pcre \
    php7.4-redis \
    php7.4-soap \
    php7.4-sqlite3 \
    php7.4-xdebug \
    php7.4-xml \
    php7.4-xsl \
    php7.4-zip \
    php8.1 \
    php8.1-bcmath \
    php8.1-cli \
    php8.1-common \
    php8.1-ctype \
    php8.1-curl \
    php8.1-dev \
    php-directory-scanner \
    php-dompdf \
    php8.1-dom \
    php8.1-fileinfo \
    php8.1-fpm \
    php8.1-gd \
#    php-symfony-password-hasher \
#    php-symfony-polyfill-iconv \
    php-imagick \
    php8.1-intl \
    php-json \
    php8.1-ldap \
    php8.1-mbstring \
    php8.1-mcrypt \
    php8.1-mysql \
    php-pear \
#    php-composer-pcre \
    php8.1-redis \
    php8.1-soap \
    php8.1-sqlite3 \
    php8.1-xdebug \
    php8.1-xml \
    php8.1-xsl \
    php8.1-zip \
    sendmail \
    sudo \
    tar \
    unzip \
#    vi \
    vim \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# add user and create ssh folder
RUN useradd -m $USER && echo "$USER:mage123" | chpasswd && adduser $USER sudo
RUN mkdir -p /home/$USER/.ssh
RUN chown -R $USER:$USER /home/$USER/.ssh

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --version=2.3.4 --filename=composer

COPY m24.conf /etc/apache2/sites-available/m24.conf
COPY php7.4cli.ini /etc/php/7.4/cli/php.ini
COPY php7.4fpm.ini /etc/php/7.4/fpm/php.ini
COPY php8.1cli.ini /etc/php/8.1/cli/php.ini
COPY php8.1fpm.ini /etc/php/8.1/fpm/php.ini
COPY xdebug.ini /etc/php/7.4/mods-available/
COPY xdebug.ini /etc/php/8.1/mods-available/
COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

USER root

# workdir
WORKDIR /home/$USER

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/bin/bash"]
