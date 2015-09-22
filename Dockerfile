FROM php:5.6-cli
MAINTAINER Raymond Rutjes <raymond.rutjes@gmail.com>

# Packages
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    zlib1g-dev \
  && rm -r /var/lib/apt/lists/*

# PHP configuration
RUN docker-php-ext-install zip
RUN echo "memory_limit=1024M" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Display version information
RUN composer --version

# Environmental Variables
ENV COMPOSER_HOME /home/composer

# Set up the application directory
VOLUME ["/app", "${COMPOSER_HOME}"]
WORKDIR /app

# Install gosu to be able to dynamically change the user of the container
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && chmod +x /usr/local/bin/gosu

# Can optionally be changed so that the downloaded files have the correct permissions
ENV USER_ID 1000
ENV GROUP_ID 1000

COPY entrypoint.sh /

CMD ["install"]
ENTRYPOINT ["/entrypoint.sh"]
