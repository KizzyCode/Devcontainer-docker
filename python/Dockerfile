FROM debian:stable-slim AS codex

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


FROM debian:stable-slim

ENV APT_PACKAGES bubblewrap build-essential ca-certificates curl git python3 python3-pip
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

RUN useradd --shell=/usr/bin/bash --uid=10000 container
USER container
WORKDIR /home/container/

COPY --from=codex --chown=0:0 --chmod=u=rwx,g=rx,o=rx /tmp/codex /usr/bin/codex

RUN mkdir .config
