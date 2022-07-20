# Create Private Keys and Certificates required by k3s and the Default Kubeconfig

# Generate Server, Client & Request Header CA Keys + Default Client Admin Key
resource "tls_private_key" "keys" {
  for_each    = setunion(local.ca_names, local.client_names)
  algorithm   = "ECDSA" # ECDSA key
  ecdsa_curve = "P256"  # P256 elliptic curve
}

# Generate Server, Client & Request Header CA Certificates
resource "tls_self_signed_cert" "ca_certs" {

  for_each = local.ca_names

  private_key_pem = tls_private_key.keys[each.key].private_key_pem

  subject {
    common_name = "k3s-${each.key}-ca@${formatdate("YYYYMMDDhhmmss", timestamp())}"
  }

  is_ca_certificate = true

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  lifecycle {
    ignore_changes = [subject]
  }
}

# Default Client Admin User Certificate (Signed by Client CA)
resource "tls_cert_request" "client_admin_user" {
  private_key_pem = tls_private_key.keys["client-admin"].private_key_pem

  subject {
    common_name  = "system:admin"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "client_admin_user" {
  cert_request_pem   = tls_cert_request.client_admin_user.cert_request_pem
  ca_private_key_pem = tls_private_key.keys["client"].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_certs["client"].cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}