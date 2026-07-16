#!/bin/sh
set -euo pipefail

if test -z "${AGENTMOUNTROOT:-}"; then
    AGENTMOUNTROOT="./"
fi

if ! test -f "$AGENTMOUNTROOT/opencode.json"; then
    echo "!> $AGENTMOUNTROOT/opencode.json not found"
    exit 1
fi

if ! test -f "/opt/homebrew/etc/ca-certificates/cert.pem"; then
    echo "!> /opt/homebrew/etc/ca-certificates/cert.pem not found"
    exit 1
fi

mkdir -p "$AGENTMOUNTROOT/shared"
exec container run \
    --interactive --tty --init --remove --rosetta \
    --volume "/opt/homebrew/etc/ca-certificates/cert.pem:/etc/ssl/certs/custom-codex-ca-certificate.pem:ro" \
    --volume "$AGENTMOUNTROOT/shared:/home/container/shared:rw" \
    --volume "$AGENTMOUNTROOT/codex:/home/container/.codex:rw" \
    --env "CODEX_CA_CERTIFICATE=/etc/ssl/certs/custom-codex-ca-certificate.pem" \
    --entrypoint /bin/bash \
    --workdir /home/container/shared \
    --cap-drop ALL \
    --cpus 4 \
    --memory 6G \
    ghcr.io/kizzycode/devcontainer:python 
