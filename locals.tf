locals {

  flannel_iface = "ens10" # https://docs.hetzner.com/cloud/networks/server-configuration/#debian--ubuntu

  server_label = "server"
  agent_labels = concat([
    "node.kubernetes.io/provisioner=terraform",
    "node.kubernetes.io/type=agent",
    "node.kubernetes.io/engine=k3s"
    ], var.sys_upgrade_ctrl ? [
    ["system_upgrade=true"]
  ] : [])

  critical_addons_only_true = "--node-taint \"CriticalAddonsOnly=true:NoExecute\" \\"

  taint_critical = var.server_taint_criticalonly == true ? local.critical_addons_only_true : "\\"

  # The main network cidr that all subnets will be created upon
  network_ipv4_cidr = "10.0.0.0/8"

  agent_nodes = merge([
    for pool_index, nodepool_obj in var.agent_nodepools : {
      for node_index in range(nodepool_obj.count) :
      format("%s-%s-%s", pool_index, node_index, nodepool_obj.name) => {
        nodepool_name : format("%s-%s", node_index, nodepool_obj.name),
        server_type : nodepool_obj.server_type,
        location : nodepool_obj.location,
        channel : nodepool_obj.channel,
        labels : concat(local.agent_labels, nodepool_obj.labels),
        taints : nodepool_obj.taints,
        index : node_index
      }
    }
  ]...)

  agent_count = sum([for v in var.agent_nodepools : v.count])

  # --- START k3s Manifest Templates ---
  # Kubernetes Dashboard
  k8s_dash_yaml_tpl = var.k8s_dashboard == true ? templatefile("${path.module}/manifests/templates/cloud-init/write_k8s_dash.tftpl", {
    k8s_dash_yaml = base64gzip(file("${path.module}/manifests/kubernetes_dashboard.yaml"))
  }) : ""

  # System Upgrade Controller
  sys_upgrade_ctrl_yaml_tpl = var.sys_upgrade_ctrl == true ? templatefile("${path.module}/manifests/templates/cloud-init/write_sys_upgrade.tftpl", {
    sys_upgrade_ctrl_yaml = base64gzip(file("${path.module}/manifests/system_upgrade_controller.yaml"))
  }) : ""

  # Cert Manager
  cert_manager_yaml_tpl = var.install_cert_manager == true ? templatefile("${path.module}/manifests/templates/cloud-init/write_cert_manager.tftpl", {
    cert_manager_yaml = base64gzip(file("${path.module}/manifests/cert_manager.yaml"))
  }) : ""
  # --- END k3s Manifest Templates ---

  # Kubeconfig TLS Resources
  ca_names = toset(["server", "client", "request-header"])

  client_names = toset(["client-admin"])

  certificate-authority-data = tls_self_signed_cert.ca_certs["server"].cert_pem

  client-certificate-data = trimspace(join("", [
    tls_locally_signed_cert.client_admin_user.cert_pem,
    tls_self_signed_cert.ca_certs["client"].cert_pem
  ]))

  client-key-data = tls_private_key.keys["client-admin"].private_key_pem

  # Generate Default Kubeconfig
  kubeconfig = yamlencode({
    "apiVersion" : "v1",
    "clusters" : [{
      "cluster" : {
        "certificate-authority-data" : base64encode(local.certificate-authority-data),
        "server" : "https://${hcloud_load_balancer.k3s_api_lb.ipv4}:6443"
      },
      "name" : "default"
    }]
    "contexts" : [{
      "context" : {
        "cluster" : "default",
        "user" : "default"
      },
      "name" : "default"
    }]
    "current-context" : "default",
    "kind" : "Config",
    "preferences" : {},
    "users" : [{
      "name" : "default",
      "user" : {
        "client-certificate-data" : base64encode(local.client-certificate-data),
        "client-key-data" : base64encode(local.client-key-data)
      }
    }]
  })

  # The following IPs are important to be whitelisted because they communicate with Hetzner services and enable the CCM and CSI to work properly.
  # Source https://github.com/hetznercloud/csi-driver/issues/204#issuecomment-848625566
  hetzner_metadata_services_ipv4 = "169.254.169.254/32"
  hetzner_cloud_api_ipv4        = "213.239.246.1/32"

  # internal Pod CIDR, used for the controller and currently for calico
  cluster_cidr_ipv4 = "10.42.0.0/16"

  whitelisted_ips = [
    local.network_ipv4_cidr,
    local.hetzner_metadata_service_ipv4,
    local.hetzner_cloud_api_ipv4,
    "127.0.0.1/32",
  ]

  base_firewall_rules = concat([
    # Allowing internal cluster traffic and Hetzner metadata service and cloud API IPs
    {
      direction  = "in"
      protocol   = "tcp"
      port       = "any"
      source_ips = local.whitelisted_ips
    },
    {
      direction  = "in"
      protocol   = "udp"
      port       = "any"
      source_ips = local.whitelisted_ips
    },
    {
      direction  = "in"
      protocol   = "icmp"
      source_ips = local.whitelisted_ips
    },

    # Allow all traffic to the kube api server
    {
      direction = "in"
      protocol  = "tcp"
      port      = "6443"
      source_ips = [
        "10.0.0.0/8",
        "127.0.0.1/32"
      ]
    },

    # Allow all traffic to the ssh port
    {
      direction = "in"
      protocol  = "tcp"
      port      = "22"
      source_ips = [
        "0.0.0.0/0"
      ]
    },

    # Allow basic out traffic
    # ICMP to ping outside services
    {
      direction = "out"
      protocol  = "icmp"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    # DNS
    {
      direction = "out"
      protocol  = "tcp"
      port      = "53"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },
    {
      direction = "out"
      protocol  = "udp"
      port      = "53"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    # HTTP(s)
    {
      direction = "out"
      protocol  = "tcp"
      port      = "80"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },
    {
      direction = "out"
      protocol  = "tcp"
      port      = "443"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    #NTP
    {
      direction = "out"
      protocol  = "udp"
      port      = "123"
      destination_ips = [
        "0.0.0.0/0"
      ]
    }
    ]
  )
}