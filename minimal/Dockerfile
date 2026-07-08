FROM debian:stable-slim

ENV APT_PACKAGES build-essential ca-certificates curl git
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

ADD --chown=10000:10000 https://opencode.ai/install .setup/opencode.sh
RUN bash .setup/opencode.sh

COPY .profile .profile
