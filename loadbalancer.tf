resource "hcloud_load_balancer" "k3s_api_lb" {
  name               = "k3s-api-lb"
  load_balancer_type = "lb11"
  location           = var.location
  algorithm {
    type = "least_connections"
  }
  labels = {
    provisioner = "terraform"
  }
}

resource "hcloud_load_balancer_network" "k3s_network" {
  load_balancer_id = hcloud_load_balancer.k3s_api_lb.id
  subnet_id        = hcloud_network_subnet.k3s_net.id
  #ip               = "10.1.0.1"
}

resource "hcloud_load_balancer_target" "k3s_api_lb_target" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.k3s_api_lb.id
  label_selector   = "type=${local.server_label}"
  use_private_ip   = true

  depends_on = [
    hcloud_server.server_node_init[0]
  ]
}

resource "hcloud_load_balancer_service" "k3s_api_service" {
  load_balancer_id = hcloud_load_balancer.k3s_api_lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}