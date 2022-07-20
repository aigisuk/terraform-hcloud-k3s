resource "hcloud_firewall" "k3s" {
  name = "k3s-cluster"

  dynamic "rule" {
    for_each = concat(local.base_firewall_rules)
    content {
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      port            = lookup(rule.value, "port", null)
      destination_ips = lookup(rule.value, "destination_ips", [])
      source_ips      = lookup(rule.value, "source_ips", [])
    }
  }
}