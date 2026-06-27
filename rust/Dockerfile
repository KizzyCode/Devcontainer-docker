FROM debian:stable-slim

ENV APT_PACKAGES build-essential ca-certificates curl git lldb
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

RUN useradd --shell=/usr/bin/bash --uid=10000 rust
USER rust
WORKDIR /home/rust/

ADD --chown=10000:10000 https://opencode.ai/install .setup/opencode.sh
RUN bash .setup/opencode.sh

ADD --chown=10000:10000 https://sh.rustup.rs .setup/rustup.sh
RUN bash .setup/rustup.sh -y
RUN .cargo/bin/rustup toolchain install nightly
RUN .cargo/bin/rustup target add thumbv6m-none-eabi
RUN .cargo/bin/rustup target add thumbv8m.main-none-eabihf

COPY .profile .profile
