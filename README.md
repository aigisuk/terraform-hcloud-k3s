# Terraform Hetzner Cloud K3S Module
An opinionated Terraform module to provision a high availability [K3s](https://k3s.io/) cluster with embedded `etcd` on the Hetzner Cloud platform. Perfect for development/testing or production workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | >= 1.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | >= 1.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.k3s](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_load_balancer.k3s_api_lb](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.k3s_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.k3s_api_service](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.k3s_api_lb_target](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_network.k3s_net](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.k3s_net](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.k3s_agent_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_placement_group.k3s_server_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.agent_node](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.server_node](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.server_node_init](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.default](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [random_id.agent_node_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.server_node_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.k3s_agent_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_cert_request.client_admin_user](https://registry.terraform.io/providers/hashicorp/tls/3.4.0/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.client_admin_user](https://registry.terraform.io/providers/hashicorp/tls/3.4.0/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.keys](https://registry.terraform.io/providers/hashicorp/tls/3.4.0/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca_certs](https://registry.terraform.io/providers/hashicorp/tls/3.4.0/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_nodepools"></a> [agent\_nodepools](#input\_agent\_nodepools) | Number of agent nodes to provision | `list(any)` | `[]` | no |
| <a name="input_flannel_backend"></a> [flannel\_backend](#input\_flannel\_backend) | Flannel Backend Type. Valid options include vxlan (default), ipsec or wireguard | `string` | `"vxlan"` | no |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner Cloud API Token | `string` | n/a | yes |
| <a name="input_install_cert_manager"></a> [install\_cert\_manager](#input\_install\_cert\_manager) | Pre-install cert-manager? | `bool` | `false` | no |
| <a name="input_k3s_channel"></a> [k3s\_channel](#input\_k3s\_channel) | K3s release channel. 'stable', 'latest', 'testing' or a specific channel or version e.g. 'v1.20', 'v1.21.0+k3s1' | `string` | `"stable"` | no |
| <a name="input_k3s_network_range"></a> [k3s\_network\_range](#input\_k3s\_network\_range) | Range of IP addresses for the network in CIDR notation. Must be one of the private ipv4 ranges of RFC1918 | `string` | `"10.0.0.0/8"` | no |
| <a name="input_k8s_dashboard"></a> [k8s\_dashboard](#input\_k8s\_dashboard) | Pre-install the Kubernetes Dashboard? (Default is false) | `bool` | `false` | no |
| <a name="input_k8s_dashboard_version"></a> [k8s\_dashboard\_version](#input\_k8s\_dashboard\_version) | Kubernetes Dashboard version | `string` | `"2.6.0"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location in which to provision the cluster. Default is nbg1 (Nuremberg, Germany) | `string` | `"nbg1"` | no |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | Number of server (master) nodes to provision | `number` | `3` | no |
| <a name="input_server_taint_criticalonly"></a> [server\_taint\_criticalonly](#input\_server\_taint\_criticalonly) | Allow only critical addons to be scheduled on servers? (thus preventing workloads from being launched on them) | `bool` | `true` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private Key | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH Public Key | `string` | n/a | yes |
| <a name="input_ssh_public_key_name"></a> [ssh\_public\_key\_name](#input\_ssh\_public\_key\_name) | SSH Public Key Name | `string` | `"default"` | no |
| <a name="input_sys_upgrade_ctrl"></a> [sys\_upgrade\_ctrl](#input\_sys\_upgrade\_ctrl) | Pre-install the System Upgrade Controller? | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Cluster default kubeconfig |
| <a name="output_local_agent_nodepools"></a> [local\_agent\_nodepools](#output\_local\_agent\_nodepools) | n/a |
<!-- END_TF_DOCS -->