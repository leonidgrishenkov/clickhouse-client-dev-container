# debian:stable-20251117-slim
FROM docker.io/debian@sha256:7cb087f19bcc175b96fbe4c2aef42ed00733a659581a80f6ebccfd8fe3185a3d

USER root

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q \
    && apt-get install -y --no-install-recommends -q sudo=1.9.* \
    curl=8.14.* \
    gnupg=2.4.* \
    wget=1.25.* \
    locales=2.4* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TZ=UTC

COPY --chown=root:root --chmod=700 ./install-ch.sh /tmp/install-ch.sh

RUN /tmp/install-ch.sh \
    rm /tmp/install-ch.sh \
    clickhouse-client --version

RUN useradd -m -u 1000 -G sudo -s /bin/bash chuser \
    && echo "chuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/chuser \
    && chmod 0440 /etc/sudoers.d/chuser

USER chuser
ENV HOME=/home/chuser TERM=xterm-256color

SHELL ["/bin/bash", "-c"]

WORKDIR $HOME

CMD ["tail", "-f", "/dev/null"]
