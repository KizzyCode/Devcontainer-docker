FROM debian:stable-slim

ENV APT_PACKAGES build-essential ca-certificates curl git
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

RUN useradd --shell=/usr/bin/bash --uid=10000 container
USER container
WORKDIR /home/container/

RUN mkdir .config

ADD --chown=10000:10000 https://opencode.ai/install .setup/opencode.sh
RUN bash .setup/opencode.sh

COPY .bashrc .bashrc
