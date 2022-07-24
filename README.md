# Terraform Hetzner Cloud K3S Module
An opinionated Terraform module to provision a high availability [K3s](https://k3s.io/) cluster with embedded `etcd` on the Hetzner Cloud platform. Perfect for development/testing or production workloads.

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner Cloud API Token | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private Key | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH Public Key | `string` | n/a | yes |
| <a name="input_agent_nodepools"></a> [agent\_nodepools](#input\_agent\_nodepools) | Number of agent nodes to provision | `list(any)` | `[]` | no |
| <a name="input_flannel_backend"></a> [flannel\_backend](#input\_flannel\_backend) | Flannel Backend Type. Valid options include vxlan (default), ipsec, wireguard or wireguard-native | `string` | `"vxlan"` | no |
| <a name="input_install_cert_manager"></a> [install\_cert\_manager](#input\_install\_cert\_manager) | Pre-install cert-manager? | `bool` | `false` | no |
| <a name="input_k3s_channel"></a> [k3s\_channel](#input\_k3s\_channel) | K3s release channel. 'stable', 'latest', 'testing' or a specific channel or version e.g. 'v1.20', 'v1.21.0+k3s1' | `string` | `"stable"` | no |
| <a name="input_k3s_network_range"></a> [k3s\_network\_range](#input\_k3s\_network\_range) | Range of IP addresses for the network in CIDR notation. Must be one of the private ipv4 ranges of RFC1918 | `string` | `"10.0.0.0/8"` | no |
| <a name="input_k8s_dashboard"></a> [k8s\_dashboard](#input\_k8s\_dashboard) | Pre-install the Kubernetes Dashboard? (Default is false) | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Location in which to provision the cluster. Default is nbg1 (Nuremberg, Germany) | `string` | `"nbg1"` | no |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | Number of server (master) nodes to provision | `number` | `3` | no |
| <a name="input_server_taint_criticalonly"></a> [server\_taint\_criticalonly](#input\_server\_taint\_criticalonly) | Allow only critical addons to be scheduled on servers? (thus preventing workloads from being launched on them) | `bool` | `true` | no |
| <a name="input_ssh_public_key_name"></a> [ssh\_public\_key\_name](#input\_ssh\_public\_key\_name) | SSH Public Key Name | `string` | `"default"` | no |
| <a name="input_sys_upgrade_ctrl"></a> [sys\_upgrade\_ctrl](#input\_sys\_upgrade\_ctrl) | Pre-install the System Upgrade Controller? | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Cluster default kubeconfig |
| <a name="output_local_agent_nodepools"></a> [local\_agent\_nodepools](#output\_local\_agent\_nodepools) | Configuration of provisioned agent nodepools |
<!-- END_TF_DOCS -->