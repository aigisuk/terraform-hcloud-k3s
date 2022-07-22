# GitHub Actions Deployment Example

This example is specifically for module tests via GitHub Actions.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| hcloud_token | Hetzner Cloud API Token | string | N/A | yes |
| ssh_private_key | SSH Private Key | string | N/A | yes |
| ssh_public_key | SSH Public Key | string | N/A | yes |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | kubeconfig for access to the cluster. |
