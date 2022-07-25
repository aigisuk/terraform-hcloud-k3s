variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key"
}

variable "ssh_public_key_name" {
  type        = string
  description = "SSH Public Key Name"
  default     = "default"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private Key"
  sensitive   = true
}

variable "location" {
  type        = string
  description = "Location in which to provision the cluster. Default is nbg1 (Nuremberg, Germany)"
  default     = "nbg1"
  validation {
    condition     = length(regexall("^nbg1|fsn1|hel1|ash$", var.location)) > 0
    error_message = "Invalid location. Valid locations include nbg1 (default), fsn1, hel2, ash"
  }
}

variable "k3s_network_range" {
  type        = string
  description = "Range of IP addresses for the network in CIDR notation. Must be one of the private ipv4 ranges of RFC1918"
  default     = "10.0.0.0/8"
}

variable "k3s_channel" {
  type        = string
  description = "K3s release channel. 'stable', 'latest', 'testing' or a specific channel or version e.g. 'v1.20', 'v1.21.0+k3s1'"
  default     = "stable"
}

variable "flannel_backend" {
  type        = string
  description = "Flannel Backend Type. Valid options include vxlan (default), ipsec, wireguard or wireguard-native"
  default     = "vxlan"
  validation {
    condition     = length(regexall("^ipsec|vxlan|wireguard|wireguard-native$", var.flannel_backend)) > 0
    error_message = "Invalid Flannel backend value. Valid backend types are vxlan, ipsec, wireguard & wireguard-native."
  }
}

variable "server_count" {
  type        = number
  description = "Number of server (master) nodes to provision"
  default     = 3
}

variable "agent_nodepools" {
  description = "Configure Agent nodepools"
  type        = list(any)
  default     = []
}

variable "server_taint_criticalonly" {
  type        = bool
  description = "Allow only critical addons to be scheduled on servers? (prevents workloads being launched on them)"
  default     = true
}

variable "k8s_dashboard" {
  type        = bool
  description = "Pre-install the Kubernetes Dashboard?"
  default     = false
}

variable "sys_upgrade_ctrl" {
  type        = bool
  description = "Pre-install the System Upgrade Controller?"
  default     = false
}

variable "install_cert_manager" {
  type        = bool
  description = "Pre-install cert-manager?"
  default     = false
}