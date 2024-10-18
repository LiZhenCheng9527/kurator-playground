## Background

Currently, Kmesh connects to the Istio control plane. Before starting Kmesh, install the Istio control plane software. We recommend installing istio ambient mode because Kmesh ads mode need it. For details, see [ambient mode istio](https://istio.io/latest/docs/ambient/getting-started/).

Note that the Kubernetes Gateway API CRDs do not come installed by default on most Kubernetes clusters, so make sure they are installed before using the Gateway API:

```sh
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml; }
```

RUN `istioctl install --set profile=ambient --skip-confirmation` {{exec}}

RUN `kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml` {{exec}}

Wait for component installation to complete.
