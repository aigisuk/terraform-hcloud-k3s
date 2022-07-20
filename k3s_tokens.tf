resource "random_password" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}

resource "random_password" "k3s_agent_token" {
  length  = 48
  upper   = false
  special = false
}