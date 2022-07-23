# Create initial K3s server node
resource "hcloud_server" "server_node" {
  count              = var.server_count - 1
  name               = "k3s-server-${count.index + 2}-${var.location}-${random_id.server_node_id[count.index + 1].hex}"
  image              = "ubuntu-22.04"
  server_type        = "cx11"
  placement_group_id = element(hcloud_placement_group.k3s_server_placement_group.*.id, ceil(count.index / 10))
  firewall_ids       = [hcloud_firewall.k3s.id]
  location           = var.location
  ssh_keys           = [var.ssh_public_key_name]
  labels = {
    provisioner = "terraform",
    engine      = "k3s"
    type        = "server"
  }
  # Prevent destroying the whole cluster if the user changes any of the attributes
  # that force to recreate the servers or network ip's/mac addresses.
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
    #ip         = "10.1.0.3"
  }
  user_data = templatefile("${path.module}/user_data/server/server.yaml.tftpl", {
    install_script = base64gzip(templatefile("${path.module}/user_data/server/server_install.sh", {
      sleep_period           = (30 * count.index) # Server nodes cannot join the cluster (etcd) simultaneously. Sleep workaround avoids a join failure. (Note: unreliable method)
      server_init_private_ip = hcloud_server.server_node_init[0].network.*.ip[0]
      k3s_channel            = var.k3s_channel
      k3s_token              = random_password.k3s_token.result
      k3s_agent_token        = random_password.k3s_agent_token.result
      critical_taint         = local.taint_critical
      flannel_backend        = var.flannel_backend
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