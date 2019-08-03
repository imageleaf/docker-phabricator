#
# Docker image for running https://github.com/phacility/phabricator
#

FROM debian:buster
MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# TODO: review this dependency list
RUN apt-get clean \
    && apt-get update \
    && apt-get install -y \
        git \
        apache2 \
        curl \
        libapache2-mod-php7.3 \
        default-libmysqlclient-dev \
        mercurial \
        default-mysql-client \
        php7.3 \
        php-apcu \
        php7.3-cli \
        php7.3-curl \
        php7.3-gd \
        php7.3-json \
        php7.3-ldap \
        php7.3-mysqlnd \
        php7.3-mbstring \
        python-pygments \
        sendmail \
        subversion \
        tar \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# For some reason phabricator doesn't have tagged releases. To support
# repeatable builds use the latest SHA
COPY download.sh /opt/download.sh

ARG PHABRICATOR_COMMIT
ARG ARCANIST_COMMIT
ARG LIBPHUTIL_COMMIT

WORKDIR /opt
RUN bash download.sh phabricator $PHABRICATOR_COMMIT
RUN bash download.sh arcanist $ARCANIST_COMMIT
RUN bash download.sh libphutil $LIBPHUTIL_COMMIT

# Setup apache
RUN a2enmod rewrite
COPY phabricator.conf /etc/apache2/sites-available/phabricator.conf
RUN ln -s /etc/apache2/sites-available/phabricator.conf /etc/apache2/sites-enabled/phabricator.conf \
    && rm -f /etc/apache2/sites-enabled/000-default.conf

# Setup phabricator
ARG TIMEZONE=UTC
RUN mkdir -p /opt/phabricator/conf/local /var/repo
COPY preamble.php /opt/phabricator/support/preamble.php
COPY local.json /opt/phabricator/conf/local/local.json
RUN sed -e 's/post_max_size =.*/post_max_size = 64M/' \
          -e 's/upload_max_filesize =.*/upload_max_filesize = 64M/' \
          -e 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/' \
          -e 's/;always_populate_raw_post_data =.*/always_populate_raw_post_data = -1/' \
          -e "s/;date.timezone =.*/date.timezone = ${TIMEZONE}/" \
          -e 's/;mysqli.allow_local_infile =.*/mysqli.allow_local_infile = 0/' \
          -i /etc/php/7.3/apache2/php.ini
RUN sed -e 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/' \
          -e "s/;date.timezone =.*/date.timezone = ${TIMEZONE}/" \
          -e 's/;mysqli.allow_local_infile =.*/mysqli.allow_local_infile = 0/' \
          -i /etc/php/7.3/cli/php.ini
RUN ln -sT /usr/lib/git-core/git-http-backend /opt/phabricator/support/bin/git-http-backend
RUN /opt/phabricator/bin/config set phd.user "root"
RUN echo "www-data ALL=(ALL) SETENV: NOPASSWD: /opt/phabricator/support/bin/git-http-backend" >> /etc/sudoers

VOLUME ["/opt/phabricator/conf", "/var/repo", "/var/log"]

EXPOSE 80
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start-server"]
