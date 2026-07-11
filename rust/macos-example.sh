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
    --volume "/opt/homebrew/etc/ca-certificates/cert.pem:/home/container/.config/ca.pem:ro" \
    --volume "$AGENTMOUNTROOT/opencode.json:/home/container/.config/opencode.json:ro" \
    --volume "$AGENTMOUNTROOT/shared:/home/container/shared:rw" \
    --env "OPENCODE_CONFIG=/home/container/.config/opencode.json" \
    --env "NODE_EXTRA_CA_CERTS=/home/container/.config/ca.pem" \
    --entrypoint /bin/bash \
    --workdir /home/container/shared \
    --cap-drop ALL \
    --cpus 4 \
    --memory 6G \
    ghcr.io/kizzycode/devcontainer:rust 
