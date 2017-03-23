FROM php:7.1-fpm

MAINTAINER Tran Duc Thang <thangtd90@gmail.com>
MAINTAINER Dmitry Momot <mail@dmomot.com>

ENV TERM xterm

RUN apt-get update \
    && apt-get install -y software-properties-common python-software-properties \
    && add-apt-repository ppa:ondrej/php \
    && cat /etc/apt/sources.list.d/ondrej-php-jessie.list \
    && sed -i -- 's/jessie/trusty/g' /etc/apt/sources.list.d/ondrej-php-jessie.list \
    && cat /etc/apt/sources.list.d/ondrej-php-jessie.list

RUN apt-get update && apt-get install -y --force-yes \
    libpq-dev \
    libmemcached-dev \
    php-memcached \
    curl \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    vim \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

# Install mongodb, xdebug
RUN pecl install mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install extensions using the helper script provided by the base image
RUN docker-php-ext-install \
    mcrypt \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    zip

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN usermod -u 1000 www-data

WORKDIR /var/www/laravel

ADD ./laravel.ini /usr/local/etc/php/conf.d
ADD ./laravel.pool.conf /usr/local/etc/php-fpm.d/

CMD ["php-fpm"]

EXPOSE 9000
