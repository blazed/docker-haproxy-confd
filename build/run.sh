#!/bin/bash

set -eo pipefail

ETCD_PORT=${ETCD_PORT:-2379}
ETCD_HOST=${ETCD_HOST:-172.17.42.1}
ETCD=$ETCD_HOST:$ETCD_PORT
CONFD=/usr/local/bin/confd
TOML=/etc/confd/conf.d/haproxy.toml

echo "[haproxy] booting container. ETCD: $ETCD"

until ${CONFD} -onetime -node ${ETCD} -config-file ${TOML}; do
  echo "[haproxy] waiting for confd to create intitial haproxy configuration."
  sleep 5
done

${CONFD} -interval 10 -node ${ETCD} -config-file ${TOML} &
echo "[haproxy] confd is now monitoring etcd for changes..."

# Start the Haproxy service using the generated config
echo "[haproxy] starting haproxy service..."
exec /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg