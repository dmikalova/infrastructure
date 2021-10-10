# Service account container registry

Adds a container registry to the default service account.

Due to the service account being the default in the cluster, it must first be imported into Terraform state:

```sh
terragrunt import kubernetes_service_account.serviceaccount_default default/default
```
