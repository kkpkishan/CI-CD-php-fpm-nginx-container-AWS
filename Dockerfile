FROM php:7.0-fpm
MAINTAINER Khatrani Kishan  <kkpkishan@gmail.com>
RUN apt-get update -y
RUN apt-get install net-tools -y
RUN apt-get install nginx -y
RUN apt-get install supervisor -y

RUN apt-get install -y libmcrypt-dev libgmp-dev openssl zip unzip libxml2-dev
RUN apt-get install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-install bcmath
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap

# Install various PHP extensions
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql \    
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-install \
        bcmath \        
        mbstring \
        mcrypt \
        mysqli \
        pdo_mysql \        
        soap \
        sockets

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./docker_data/site.conf /etc/nginx/sites-available/default
COPY ./docker_data/nginx.conf /etc/nginx/nginx.conf

WORKDIR /code
COPY ./source/ /code/
COPY ./docker_data/supervisord.conf /etc/supervisor.conf


#RUN composer install

RUN rm -f /usr/local/etc/php/php.ini*
RUN rm -f /usr/local/etc/php-fpm.conf.default
RUN rm -f /usr/local/etc/php-fpm.d/www.conf.default
COPY ./docker_data/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker_data/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./docker_data/php.ini /usr/local/etc/php/php.ini
COPY ./docker_data/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
RUN rm -f /usr/local/etc/php-fpm.d/docker.conf
EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor.conf"]
