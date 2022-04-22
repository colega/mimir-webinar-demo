#!/usr/bin/env bash
# vim: ai:ts=8:sw=8:noet

set -eufo pipefail
export SHELLOPTS
IFS=$'\t\n'
umask 0077

# Demo k9s host is where the k9s api server is running.
DEMO_K8S_HOST=${DEMO_K8S_HOST:?Should provide the host of the k9s demo as DEMO_K8S_HOST}

# Demo kubeconfig file can be overriden to a custom location if needed.
DEMO_KUBECONFIG=${DEMO_KUBECONFIG:-$PWD/k3s.yaml}

echo "Installing k3s on $DEMO_K8S_HOST"
ssh "$DEMO_K8S_HOST" 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -l'

echo "Bringing the kubeconfig"
ssh "$DEMO_K8S_HOST" 'sudo cat /etc/rancher/k3s/k3s.yaml' | sed -e "s/127.0.0.1/$DEMO_K8S_HOST/" > "$DEMO_KUBECONFIG"
chmod 0600 "$DEMO_KUBECONFIG"

echo "Done, now set your KUBECONFIG:"
echo "  export KUBECONFIG='$DEMO_KUBECONFIG'"
