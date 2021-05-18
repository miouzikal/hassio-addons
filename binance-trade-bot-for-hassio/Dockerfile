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
RUN git clone -b master https://github.com/idkravitz/binance-trade-bot.git /tmp/bot/ && \
    pip install -r /tmp/bot/requirements.txt

# Copy root filesystem
COPY rootfs /

RUN chmod a+x /scripts/*.sh

CMD ["/scripts/run.sh"]
