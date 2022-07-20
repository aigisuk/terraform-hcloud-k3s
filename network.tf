resource "hcloud_network" "k3s_net" {
  name     = "k3s-net-01"
  ip_range = var.k3s_network_range
  labels = {
    "type" = "cluster"
  }
}

resource "hcloud_network_subnet" "k3s_net" {
  network_id   = hcloud_network.k3s_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.1.0.0/16"
}