#!/bin/bash

set -e

DEFAULT_KIND_IMAGE="kindest/node:v1.30.0@sha256:047357ac0cfea04663786a612ba1eaba9702bef25227a794b52890dd8bcd692e"

export KMESH_WAYPOINT_IMAGE=${KMESH_WAYPOINT_IMAGE:-"ghcr.io/kmesh-net/waypoint:latest"}

ROOT_DIR=$(git rev-parse --show-toplevel)

# Provision a kind clustr for testing.
function setup_kind_cluster() {
    local NAME="kmesh-testing"
    local IMAGE="${2:-"${DEFAULT_KIND_IMAGE}"}"

    # Delete any previous KinD cluster.
    echo "Deleting previous KinD cluster with name=${NAME}"
    if ! (kind delete cluster --name="${NAME}" -v9) > /dev/null; then
        echo "No existing kind cluster with name ${NAME}. Continue..."
    fi

    # Create default IPv4 KinD cluster
    cat <<EOF | kind create cluster --name="${NAME}" -v4 --retain --image "${IMAGE}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
EOF

    status=$?
    if [ $status -ne 0 ]; then
        echo "Could not setup KinD environment. Something wrong with KinD setup. Exporting logs."
    fi

    # For KinD environment we need to mount bpf for each node, ref: https://github.com/kmesh-net/kmesh/issues/662
    for node in $(kind get nodes --name="${NAME}"); do
        docker exec "${node}" sh -c "mount -t bpf none /sys/fs/bpf"
    done
}

function install_dependencies() {
    # 1. Install kind.
    if ! which kind &> /dev/null
    then
        echo "install kind"

        go install sigs.k8s.io/kind@v0.23.0
    else
        echo "kind is already installed"
    fi
    
    # 2. Install helm.
    if ! which helm &> /dev/null
    then
        echo "install helm"

        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

        chmod 700 get_helm.sh

        ./get_helm.sh

        rm get_helm.sh
    else
        echo "helm is already installed"
    fi

    # 3. Install istioctl
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh -

    cp istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/

    rm -rf istio-${ISTIO_VERSION}

    # 4. Git clone Kmesh
    git clone git@github.com:kmesh-net/kmesh.git
    cd kmesh
}


PARAMS=()

install_dependencies
setup_kind_cluster