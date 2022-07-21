# resource "local_sensitive_file" "k3s_kubeconfig" {
#   content  = local.kubeconfig
#   filename = "${path.root}/k3s.yaml"
# }