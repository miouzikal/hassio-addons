ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Home Assistant CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN curl -Lso /usr/bin/ha "https://github.com/home-assistant/cli/releases/download/${CLI_VERSION}/ha_${BUILD_ARCH}" && \
    chmod a+x /usr/bin/ha

# Build requirements
RUN apk update && apk upgrade && apk add git python3 py3-pip gcc musl-dev python3-dev libffi-dev openssl-dev cargo build-base vim

# Install knowned requirements
RUN pip install -q python-binance==0.7.9 \
                   sqlalchemy==1.3.23 \
                   schedule==1.0.0 \
                   apprise==0.9.1 \
                   Flask==1.1.2 \
                   gunicorn==20.0.4 \
                   flask-cors==3.0.10 \
                   flask-socketio==5.0.1 \
                   eventlet==0.31.0 \
                   python-socketio[client]==5.0.4 \
                   cachetools==4.2.1 \
                   sqlitedict==1.7.0

# Copy root filesystem
COPY rootfs /

RUN chmod a+x /scripts/*.sh

CMD ["/scripts/run.sh"]