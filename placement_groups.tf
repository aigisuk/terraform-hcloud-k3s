resource "hcloud_placement_group" "k3s_server_placement_group" {
  count = ceil(var.server_count / 10)
  name  = "k3s-server-group-${count.index + 1}"
  type  = "spread"
}

resource "hcloud_placement_group" "k3s_agent_placement_group" {
  count = ceil(local.agent_count / 10)
  name  = "k3s-agent-group-${count.index + 1}"
  type  = "spread"
}