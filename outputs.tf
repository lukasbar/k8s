output "control_plane_public_ip" {
  description = "Public IP address of the control plane node"
  value       = oci_core_instance.k8s_nodes[0].public_ip
}

output "control_plane_private_ip" {
  description = "Private IP address of the control plane node"
  value       = oci_core_instance.k8s_nodes[0].private_ip
}

output "worker_nodes_public_ips" {
  description = "Public IP addresses of worker nodes"
  value       = slice(oci_core_instance.k8s_nodes[*].public_ip, 1, length(oci_core_instance.k8s_nodes))
}

output "load_balancer_ip" {
  description = "IP address of the Network Load Balancer (multi-node setup only)"
  value       = var.node_count > 1 ? oci_network_load_balancer.k8s_nlb[0].ip_addresses[0] : null
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "ssh ubuntu@${oci_core_instance.k8s_nodes[0].public_ip} 'sudo microk8s config' > ~/.kube/config"
}

output "cluster_token" {
  description = "Token for joining additional nodes to the cluster"
  value       = random_string.cluster_token.result
  sensitive   = true
} 
