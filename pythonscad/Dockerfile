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
    https://github.com/openai/codex/releases/latest/download/codex-package-`uname -m`-unknown-linux-musl.tar.gz
RUN tar -xvf codex-`uname -m`-unknown-linux-musl.tar.gz


FROM debian:stable-slim

ENV APT_PACKAGES bubblewrap build-essential ca-certificates curl git libglib2.0-0 nano openssh-client python3 python3-pip rsync
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean
RUN python3 -m pip install --break-system-packages --no-cache-dir --only-binary=:all: \
    pythonscad build123d numpy ipykernel ipywidgets pythreejs
RUN python3 -m ipykernel install --prefix=/usr/local --name pythonscad --display-name PythonSCAD

RUN useradd --shell=/usr/bin/bash --uid=10000 container
USER container
WORKDIR /home/container/

COPY --chown=0:0 --chmod=u=rw,g=r,o=r ./jupyterdisplay.py /usr/local/lib/python3.13/dist-packages/jupyterdisplay.py
COPY --from=codex --chown=0:0 --chmod=u=rwx,g=rx,o=rx /tmp/bin/codex* /usr/bin/

RUN python3 -c 'import pythonscad as ps; import jupyterdisplay; import ipywidgets; assert isinstance(jupyterdisplay.build_widget(ps.cube([10, 10, 10])), ipywidgets.Widget)'

RUN mkdir .config
