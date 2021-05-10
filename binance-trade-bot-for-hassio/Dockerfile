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

# Copy root filesystem
COPY rootfs /

RUN chmod a+x /scripts/*.sh

# Install knowned requirements
RUN pip install -r /requirements.txt

CMD ["/scripts/run.sh"]