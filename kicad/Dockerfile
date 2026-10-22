FROM debian:unstable-slim AS codex

ENV APT_PACKAGES ca-certificates curl
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES}

RUN useradd --system --uid=10000 container
USER container
WORKDIR /tmp

RUN curl --location --tlsv1.2 --output codex-`uname -m`-unknown-linux-musl.tar.gz \
     https://github.com/openai/codex/releases/latest/download/codex-`uname -m`-unknown-linux-musl.tar.gz
RUN tar -xvf codex-`uname -m`-unknown-linux-musl.tar.gz
RUN ln codex-`uname -m`-unknown-linux-musl codex


FROM debian:unstable-slim

ENV APT_PACKAGES bubblewrap build-essential ca-certificates curl git kicad kicad-footprints kicad-symbols nano openjdk-25-jre-headless openssh-client python3 python3-pip python3-venv rsync
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

RUN test `kicad-cli version | cut -d . -f 1` = 10
RUN python3 -c 'import pcbnew'

RUN useradd --shell=/usr/bin/bash --uid=10000 container
USER container
WORKDIR /home/container/

COPY --from=codex --chown=0:0 --chmod=u=rwx,g=rx,o=rx /tmp/codex /usr/bin/codex
ADD --checksum=sha256:f6f51bb02245e8e717f9359bd260cc9c5c0b1bc0acc8b7cb2cd5b8ffeb5de3c7 --chown=0:0 --chmod=u=rw,g=r,o=r \
    https://github.com/freerouting/freerouting/releases/download/v2.5.0/freerouting-2.5.0.jar /usr/libexec/freerouting.jar

COPY --chown=0:0 --chmod=u=rw,g=r,o=r kicad-routing-skill.md /etc/codex/skills/kicad-routing/SKILL.md
COPY --chown=0:0 --chmod=u=rw,g=r,o=r kicad-schematic-review-skill.md /etc/codex/skills/kicad-schematic-review/SKILL.md

RUN mkdir .config
