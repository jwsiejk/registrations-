#!/usr/bin/env bash
set -euo pipefail

: "${TLS_SERVICE_NAME:?TLS_SERVICE_NAME is required}"

SRC_DIR="/opt/postgres-tls/${TLS_SERVICE_NAME}"
DST_DIR="/var/lib/postgresql/tls/${TLS_SERVICE_NAME}"

for required_file in "$SRC_DIR/server.key" "$SRC_DIR/server.crt" "$SRC_DIR/ca.crt"; do
  if [[ ! -f "$required_file" ]]; then
    echo "ERROR: Missing TLS asset: $required_file"
    echo "Run: bash infra/docker/scripts/generate-tls-certs"
    exit 1
  fi
done

install -d -m 700 "$DST_DIR"
install -m 600 "$SRC_DIR/server.key" "$DST_DIR/server.key"
install -m 644 "$SRC_DIR/server.crt" "$DST_DIR/server.crt"
install -m 644 "$SRC_DIR/ca.crt" "$DST_DIR/ca.crt"
chown postgres:postgres "$DST_DIR" "$DST_DIR/server.key" "$DST_DIR/server.crt" "$DST_DIR/ca.crt"

exec /usr/local/bin/docker-entrypoint.sh "$@" \
  -c ssl=on \
  -c ssl_cert_file="$DST_DIR/server.crt" \
  -c ssl_key_file="$DST_DIR/server.key" \
  -c ssl_ca_file="$DST_DIR/ca.crt"
