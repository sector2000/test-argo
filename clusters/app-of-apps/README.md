# app-of-apps


## Installation

Run:

```bash
helm template . --set environment=test --show-only templates/app-of-apps.yaml | oc apply -f -
```
