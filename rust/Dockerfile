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

ENV APT_PACKAGES bubblewrap build-essential ca-certificates curl git lldb nano openssh-client
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

RUN useradd --shell=/usr/bin/bash --uid=10000 rust
USER rust
WORKDIR /home/rust/

COPY --from=codex --chown=0:0 --chmod=u=rwx,g=rx,o=rx /tmp/codex /usr/bin/codex

ADD --chown=10000:10000 https://sh.rustup.rs .setup/rustup.sh
RUN bash .setup/rustup.sh -y
RUN .cargo/bin/rustup toolchain install nightly
RUN .cargo/bin/rustup target add thumbv6m-none-eabi
RUN .cargo/bin/rustup target add thumbv7em-none-eabihf
RUN .cargo/bin/rustup target add thumbv8m.main-none-eabihf

RUN .cargo/bin/cargo install flip-link

RUN mkdir .config
COPY .bashrc .bashrc
