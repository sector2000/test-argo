# app-of-apps


## Installation

Run:

```bash
helm template . -f values-all.yaml -f values-<cluster name> --show-only templates/app-of-apps.yaml | oc apply -f -
```
