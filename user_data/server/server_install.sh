#!/bin/bash

# Set Private & Public IP variables
NODE_PUBLIC_IP=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
NODE_PRIVATE_IP=$(/sbin/ip -o -4 addr list ens10 | awk '{print $4}' | cut -d/ -f1)

sleep ${sleep_period}

# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} K3S_TOKEN=${k3s_token} K3S_AGENT_TOKEN=${k3s_agent_token} K3S_URL=https://${server_init_private_ip}:6443 sh -s - server \
    --node-ip $${NODE_PRIVATE_IP} \
    --advertise-address $${NODE_PRIVATE_IP} \
    ${critical_taint}
    --flannel-backend=${flannel_backend} \
    --flannel-iface=ens10 \
    --node-label="node.kubernetes.io/created-by=terraform" \
    --disable local-storage \
    --disable-cloud-controller \
    --disable traefik \
    --disable servicelb \
    --kubelet-arg 'cloud-provider=external'