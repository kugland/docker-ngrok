FROM alpine:latest

WORKDIR /ngrok

COPY --chown=root:root ./run-ngrok.sh /usr/local/bin/run-ngrok.sh

RUN { \
  set -eux ; \
  apk add --no-cache bash sudo ; \
  sed -E -e '/^nobody:/{s,nobody,ngrok,g;s,:/:/sbin/nologin,:/ngrok:/bin/sh,g}' -i /etc/passwd ; \
  sed -E -e '/^nobody:/{s,nobody,ngrok,g}' -i /etc/group ; \
  mkdir /ngrok/.ngrok2 ; \
  touch /ngrok/.ngrok2/ngrok.yml ; \
  chown -R ngrok:ngrok /ngrok ; \
}

ENV NGROK_URL=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
ENV NGROK_SHA256=84bdc4f43df2b22e429af5bc7ae145ac8bbdc5cd0b1bd908182fdfd3c91e0b3f

RUN { \
  set -eux ; \
  wget -q -O /tmp/ngrok.zip "${NGROK_URL}" ; \
  if [[ "$(sha256sum /tmp/ngrok.zip | cut -b0-64)" != "${NGROK_SHA256}" ]]; then \
    echo "Integrity check failed!!!" ; \
  fi ; \
  unzip /tmp/ngrok.zip -d /tmp ; \
  rm /tmp/ngrok.zip ; \
  mv /tmp/ngrok /usr/local/bin/ngrok ; \
  chmod 755 /usr/local/bin/run-ngrok.sh /usr/local/bin/ngrok ; \
  chown root:root /usr/local/bin/run-ngrok.sh /usr/local/bin/ngrok ; \
}

ENTRYPOINT [ "/usr/local/bin/run-ngrok.sh" ]
