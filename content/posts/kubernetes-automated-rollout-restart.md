+++
title = 'Automated deployment rollout in Kubernetes'
date = 2024-09-16T07:47:01+01:00
+++

# Kubernetes CI/CD rollout restart

Creating a kubernetes credential with permissions to restart deployments. This
is useful in CI/CD systems that are to restart a deployment for example when a
new image has been pushed to a registry

## Create a kubeconfig to authenticate against kubernetes cluster

We will be using token auth as opposed to mtls. First we need a service account

`kubectl create sa test-sa`

Create long lived token for sa. This command makes the token valid for 10 hours
but you can set it to be valid for however long you require.

`kubectl create token test-sa --duration=10h`

Create a kube config

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <k8s server CA here>
    server: <server url here>
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    token: <paste token here>
```