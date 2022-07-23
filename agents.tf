# Create initial K3s server node
resource "hcloud_server" "agent_node" {

  for_each = local.agent_nodes

  name               = "k3s-agent-${each.value.nodepool_name}-${each.value.location}-${random_id.agent_node_id[each.value.index].hex}"
  image              = "ubuntu-22.04"
  server_type        = each.value.server_type
  placement_group_id = element(hcloud_placement_group.k3s_agent_placement_group.*.id, ceil(each.value.index / 10))
  firewall_ids       = [hcloud_firewall.k3s.id]
  location           = each.value.location
  ssh_keys           = [var.ssh_public_key_name]
  labels = {
    provisioner = "terraform",
    engine      = "k3s"
    type        = "agent"
  }
  # Prevent destroying the whole cluster if the user changes any of the attributes
  # that force recreation of servers or network ip's/mac addresses.
  lifecycle {
    ignore_changes = [
      location,
      network,
      ssh_keys,
      user_data,
    ]
  }
  network {
    network_id = hcloud_network.k3s_net.id
  }
  user_data = templatefile("${path.module}/user_data/agent/agent.yaml.tftpl", {
    k3s_channel = each.value.channel
    agent_config = base64gzip(yamlencode({
      server        = "https://${hcloud_load_balancer_network.k3s_network.ip}:6443"
      token         = random_password.k3s_agent_token.result
      flannel-iface = "ens10"
      kubelet-arg   = ["cloud-provider=external"]
      node-label    = each.value.labels
    }))
  })
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait --long > /dev/null" # wait for cloud-init to complete
    ]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
    }
  }
  depends_on = [
    hcloud_server.server_node_init
  ]
}