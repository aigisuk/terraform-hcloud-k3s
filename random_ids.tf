resource "random_id" "server_node_id" {
  byte_length = 2
  count       = var.server_count
}

resource "random_id" "agent_node_id" {
  count       = local.agent_count
  byte_length = 2
}