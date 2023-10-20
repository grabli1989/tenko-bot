ARG PROJECT_PHP_VERSION
FROM php:8.2-alpine3.16

ARG PROJECT_PHP_VERSION

RUN apk --update add wget \
  curl \
  git \
  build-base \
  libmcrypt-dev \
  libxml2-dev \
  pcre-dev \
  zlib-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  oniguruma-dev \
  libressl \
  libwebp-dev \
  libressl-dev \
  g++ \
  make \
  postgresql-dev \
  procps \
  supervisor

RUN pecl channel-update pecl.php.net; \
    docker-php-ext-install mysqli mbstring pdo pdo_mysql xml pcntl;

# Add a non-root user to help install ffmpeg:
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} www && \
    adduser -D -G www -u ${PUID} www

# Install Redis package:
RUN printf "\n" | pecl install -o -f redis; \
rm -rf /tmp/pear; \
# Install Redis Extension \
docker-php-ext-enable redis

#Install GD package:
RUN apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev zlib-dev
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd
RUN docker-php-ext-install exif

#Install ImageMagick:
RUN set -eux; \
    apk add --update --no-cache imagemagick-dev imagemagick; \
    pecl install imagick-3.7.0; \
    docker-php-ext-enable imagick; \
    php -m | grep -q 'imagick';

# Install Postgre PDO
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql

#--------------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------------

RUN rm /var/cache/apk/* \
  && mkdir -p /var/www

#
#--------------------------------------------------------------------------
# Optional Supervisord Configuration
#--------------------------------------------------------------------------
#
# Modify the ./supervisor.conf file to match your App's requirements.
# Make sure you rebuild your container with every change.
#

COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# If you need to modify this image, feel free to do it right here.
#
# -- Your awesome modifications go here -- #

#
#--------------------------------------------------------------------------
# Check PHP version
#--------------------------------------------------------------------------
#

RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

WORKDIR /etc/supervisor/conf.d/
