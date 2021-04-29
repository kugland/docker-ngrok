#!/bin/bash

NGROK_PROTO=http

case "$1" in
  http|tcp)
    NGROK_PROTO="$1"
    shift
    ;;
esac

if [[ "$1" =~ ^[0-9]+$ ]]; then
  NGROK_PORT="$1"
else
  echo 'Usage: [NGROK_AUTHTOKEN=<token>] run-ngrok.sh [<proto>] <port>'
  echo ''
  echo '<proto> is either "http" or "tcp"'
  exit 1
fi

typeset -a NGROK_CMD

DOCKER_HOST_IP="$(ip -4 route show default | cut -d' ' -f3)"
NGROK_CMD=(
  "/usr/local/bin/ngrok"
  "${NGROK_PROTO}"
  "${DOCKER_HOST_IP}:${NGROK_PORT}"
)

if [[ -n "${NGROK_AUTHTOKEN}" ]]; then
  NGROK_CMD+=("--authtoken=${NGROK_AUTHTOKEN}")
fi

exec /usr/bin/sudo -i -u ngrok "${NGROK_CMD[@]}"
