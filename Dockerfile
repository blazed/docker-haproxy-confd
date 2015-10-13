FROM alpine:3.2
MAINTAINER Boberg <blazed@darkstar.se>

ENV CONFD_VERSION 0.10.0

RUN \
  apk add --update bash haproxy curl && rm -rf /var/cache/apk/* &&\
  touch /var/log/haproxy.log &&\
  chown haproxy: /var/log/haproxy.log

ADD build/haproxy.toml /etc/confd/conf.d/haproxy.toml
ADD build/haproxy.tmpl /etc/confd/templates/haproxy.tmpl

WORKDIR /usr/local/bin/
RUN \
  curl -sSL https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 -o confd &&\
  chmod +x confd

ADD build/run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

EXPOSE 80 1936

CMD ["/opt/run.sh"]