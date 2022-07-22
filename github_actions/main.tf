terraform {
  # Reconfigure the backend block to suit your needs
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "AIGISUK"

    workspaces {
      name = "gh-actions-terraform-hcloud-k3s"
    }
  }
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
  required_version = ">= 1.2.0"
}

provider "hcloud" {}

module "hcloud_k3s" {
  source = "git::https://github.com/aigisuk/terraform-hcloud-k3s.git?ref=develop"

  hcloud_token    = var.hcloud_token
  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key
  agent_nodepools = var.agent_nodepools
}