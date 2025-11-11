# debian:trixie-20251103
FROM docker.io/debian@sha256:01a723bf5bfb21b9dda0c9a33e0538106e4d02cce8f557e118dd61259553d598

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo curl git ca-certificates locales gpg \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8
ENV TZ UTC

# TODO: what is actually apt-transport-https ?
# BUG: не получается к клику из контейнера приокннектится
RUN apt-get install -y apt-transport-https \ 
    && curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg \
    && ARCH=$(dpkg --print-architecture) \
    && echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && apt-get install -y clickhouse-client

RUN groupadd -g 1000 devs \
    && useradd -m -u 1000 -G sudo,devs -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

USER dev
ENV HOME /home/dev

USER dev
WORKDIR /home/dev
ENV TERM xterm-256color

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
