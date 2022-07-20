# Create initial K3s server node
resource "hcloud_server" "server_node_init" {
  count              = 1
  name               = "k3s-server-1-${var.location}-${random_id.server_node_id[count.index].hex}"
  image              = "ubuntu-22.04"
  server_type        = "cx11"
  placement_group_id = element(hcloud_placement_group.k3s_server_placement_group.*.id, ceil(count.index / 10))
  firewall_ids       = [hcloud_firewall.k3s.id]
  location           = var.location
  ssh_keys           = [var.ssh_public_key_name]
  labels = {
    provisioner = "terraform",
    engine      = "k3s"
    type        = local.server_label
  }
  network {
    network_id = hcloud_network.k3s_net.id
    ip         = "10.1.0.2"
  }
  user_data = templatefile("${path.module}/user_data/server/server_init.yaml.tftpl", {
    install_script = base64gzip(templatefile("${path.module}/user_data/server/server_init_install.sh", {
      k3s_channel     = var.k3s_channel
      k3s_token       = random_password.k3s_token.result
      k3s_agent_token = random_password.k3s_agent_token.result
      critical_taint  = local.taint_critical
      flannel_backend = var.flannel_backend
      k3s_lb_ip       = hcloud_load_balancer.k3s_api_lb.ipv4
    }))
    ccm_tpl = base64gzip(templatefile("${path.module}/manifests/templates/ccm.yaml.tftpl", {
      cluster_cidr_ipv4 = local.cluster_cidr_ipv4
    }))
    csi_tpl = base64gzip(file("${path.module}/manifests/csi.yaml"))
    # --- START k3s generated CA keys & certs ---
    ca_keys  = { for ca_name, key in tls_private_key.keys : ca_name => base64gzip(key.private_key_pem) if contains(local.ca_names, ca_name) }
    ca_certs = { for ca_name, cert in tls_self_signed_cert.ca_certs : ca_name => base64gzip(cert.cert_pem) }
    # --- END k3s generated keys & certs ---
    hcloud_token = var.hcloud_token
    k3s_net_id   = hcloud_network.k3s_net.id
    flannel_backend = var.flannel_backend
    k8s_dashboard    = local.k8s_dash_yaml_tpl
    sys_upgrade_ctrl = local.sys_upgrade_ctrl_yaml_tpl
    cert_manager     = local.cert_manager_yaml_tpl
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
  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.k3s_net
  ]
}