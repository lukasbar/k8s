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
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.k8s_cluster.id} --file $HOME/.kube/config --region ${var.region}"
}

output "cluster_token" {
  description = "Token for joining additional nodes to the cluster"
  value       = random_string.cluster_token.result
  sensitive   = true
}

output "cluster_id" {
  description = "The OCID of the Kubernetes cluster"
  value       = oci_containerengine_cluster.k8s_cluster.id
}

output "cluster_endpoint" {
  description = "The Kubernetes cluster endpoint"
  value       = oci_containerengine_cluster.k8s_cluster.endpoints[0].private_endpoint
}

output "node_pool_id" {
  description = "The OCID of the node pool"
  value       = oci_containerengine_node_pool.k8s_node_pool.id
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = var.cluster_name
}

output "node_count" {
  description = "Number of nodes in the cluster"
  value       = var.node_count
}

output "node_shape" {
  description = "Shape of the nodes"
  value       = var.node_shape
}

output "node_resources" {
  description = "Resources allocated to each node"
  value       = {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_in_gbs
  }
} 
