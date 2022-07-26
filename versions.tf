terraform {
  required_version = ">= 1.2.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}