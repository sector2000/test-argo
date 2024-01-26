# app-of-apps


## Installation

Run:

```
helm template . --set cluster_name=<cluster name> --show-only templates/applicationset.yaml | oc apply -f-
```
