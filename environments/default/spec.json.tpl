{
  "apiVersion": "tanka.dev/v1alpha1",
  "kind": "Environment",
  "metadata": {
    "name": "environments/default",
    "namespace": "environments/default/main.jsonnet"
  },
  "spec": {
    "apiServer": "${DEMO_K8S_HOST}:6443",
    "namespace": "default",
    "resourceDefaults": {},
    "expectVersions": {},
    "injectLabels": true
  }
}
