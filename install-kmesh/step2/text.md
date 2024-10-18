## Background

There are several ways to install Kmesh, refer to the [Kmesh doc](https://kmesh.net/en/docs/setup/quickstart/#install-kmesh).

This interactive demo uses helm to install Kmesh.

RUN `helm install kmesh ./deploy/charts/kmesh-helm -n kmesh-system --create-namespace` {{exec}}

## Check Result

RUN `kubectl get po -n kmesh-system` {{exec}}