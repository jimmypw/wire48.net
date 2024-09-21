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

`kubectl -n default create sa test-sa`

Create long lived token for sa. This command makes the token valid for 10 hours
but you can set it to be valid for however long you require.

`kubectl -n create token test-sa --duration=10h`

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

## Set up Role

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-restarter
  namespace: default
rules:
- apiGroups: ["apps", "extensions"]
  resources: ["deployments"]
  resourceNames: [] # blank list means anything
  verbs: ["get", "patch"]
```

## Set up role binding

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-restarter
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-restarter
subjects:
- kind: ServiceAccount
  name: test-sa
  namespace: default
```

## Test

`kubectl -n default --kubeconfig kubeconfig.yml rollout restart deployment foo`

If all has gone well the 'foo' deployment will restart. 

## Integrating with github

configure a secret on a project called `KUBE_CONFIG`. It needs to contain the
base64 encoded kubeconfig we create above

`base64 -w 0 service.kubeconfig`

## Call the redeployment on a pipeline 

In github actions it's done like so:

```yaml
  - uses: actions-hub/kubectl@v1.30.3
    env:
      KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
    with:
      args: -n default rollout restart deployment foo
```

And the deployment gets restarted at the end of the deployment without any
interaction.