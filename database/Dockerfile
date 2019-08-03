#
# Docker image for the phabricator database
#

FROM debian:buster
MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update \
    && apt-get install -y \
        curl \
        default-mysql-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
COPY my-phabricator.cnf /etc/mysql/conf.d/my-phabricator.cnf

ARG PHABRICATOR_COMMIT
ENV PHABRICATOR_COMMIT ${PHABRICATOR_COMMIT:-stable}
COPY download.sh /opt/mysql/download.sh
RUN bash /opt/mysql/download.sh

COPY setup.sh /opt/mysql/setup.sh
RUN bash /opt/mysql/setup.sh

EXPOSE 3306
VOLUME ["/var/lib/mysql"]
CMD mysqld_safe
