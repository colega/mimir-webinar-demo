#!/usr/bin/env bash
# vim: ai:ts=8:sw=8:noet

set -eufo pipefail
export SHELLOPTS
IFS=$'\t\n'
umask 0077

command -v envsubst >/dev/null 2>&1 || { echo 'Please install envsubst'; exit 1; }

# Demo k9s host is where the k9s api server is running.
export DEMO_K8S_HOST=${DEMO_K8S_HOST:?Should provide the host of the k9s demo as DEMO_K8S_HOST}

# Demo domain can be set to a custom one if it's not the DEMO_HOST.
export DEMO_DOMAIN=${DEMO_DOMAIN:-$DEMO_K8S_HOST}

echo "Rendering environments/default/spec.json"
envsubst < environments/default/spec.json.tpl > environments/default/spec.json

echo "Rendering environments/default/config.libsonnet"
envsubst < environments/default/config.libsonnet.tpl > environments/default/config.libsonnet

echo "Done."
