This project is used to play around with [ArgoCD](https://argoproj.github.io/cd/)

[[_TOC_]]

## Seal the secrets

Requirements:

- kubeseal
- access to the cluster ([TODO](https://gitlab.com/paluszkiewiczHome/argo-test/-/issues/1))

```bash
make seal
```

## Tests

```bash
make qa
```

There are no unit tests, however CI scripts can validate whether some conventions are followed:

- all ArgoCD CRDs must be installed in the same namespace as ArgoCD itself (otherwise it won't work)
- all Helm charts dependencies should have locks committed to the repository

Seals the secrets, which must be stored in secrets/<filename>.yaml
Those secrets **MUST NOT** be committed to Version Control System!

## Set up local environment

Requirements:

- k3d
- helm
- envsubst

```bash
make local
```