# Automated Kubernetes Cluster Deployment on Oracle Cloud Infrastructure

This project enables automatic creation and configuration of a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using ARM processors. The entire infrastructure is managed as code using Terraform, and the cluster is set up using MicroK8s.

## Project Overview

The project consists of the following components:
- **Terraform** - for automatic deployment and configuration of infrastructure in Oracle Cloud
- **Kubernetes** - cluster on ARM architecture using MicroK8s
- **Network Load Balancer** - for multi-node cluster setups
- **Security Configuration** - properly configured security lists for cluster communication

## Features

- Deploy a single-node or multi-node Kubernetes cluster (up to 4 nodes)
- Use Oracle Cloud's Always Free tier resources (ARM-based VM.Standard.A1.Flex instances)
- Automatic installation and configuration of MicroK8s
- Pre-configured security rules for cluster communication
- Network Load Balancer for multi-node setups
- Automatic installation of essential add-ons:
  - DNS
  - hostpath-storage
  - ingress
  - metrics-server

## Prerequisites

- Oracle Cloud account with access to services
- Terraform (version >= 1.0.0)
- OCI CLI configured with appropriate permissions
- kubectl
- SSH key pair
- Your public IP address (for security rules)

## Required OCI Resources

- Tenancy OCID
- User OCID
- API key with fingerprint
- Compartment OCID
- Region access

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Copy the example variables file and edit it with your values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your specific values:
   ```
   # OCI Authentication
   tenancy_ocid     = "ocid1.tenancy.oc1..example"
   user_ocid        = "ocid1.user.oc1..example"
   private_key_path = "~/.oci/oci_api_key.pem"
   fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
   region           = "eu-frankfurt-1"

   # Compartment
   compartment_id   = "ocid1.compartment.oc1..example"

   # Cluster Configuration
   cluster_name     = "k8s-cluster"
   node_count       = 1  # Set to 1 for single-node or 2-4 for multi-node
   node_shape       = "VM.Standard.A1.Flex"
   node_ocpus       = 1
   node_memory_in_gbs = 6

   # Network Configuration
   vcn_cidr         = "10.0.0.0/16"
   subnet_cidr      = "10.0.1.0/24"
   your_ip          = "YOUR_IP_ADDRESS/32"  # Your IP address with CIDR notation

   # SSH Configuration
   ssh_public_key   = "~/.ssh/id_rsa.pub"
   ssh_private_key  = "~/.ssh/id_rsa"
   ```

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the planned changes:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

7. After the infrastructure is created, configure kubectl:
   ```bash
   eval $(terraform output -raw kubeconfig_command)
   ```

## Cluster Configuration

### Single-Node Cluster
- 1 VM with 1 CPU and 6GB RAM
- Suitable for development and testing
- All components run on a single node

### Multi-Node Cluster
- Up to 4 VMs, each with 1 CPU and 6GB RAM
- First node acts as the control plane
- Additional nodes join as workers
- Network Load Balancer for API server access

## Network Configuration

The infrastructure includes:
- VCN with a public subnet
- Internet Gateway for external access
- Security lists with rules for:
  - SSH access (port 22) from your IP
  - Kubernetes API (port 6443) from your IP and cluster nodes
  - etcd communication (ports 2379-2380) between nodes
  - kubelet communication (port 10250) between nodes
  - HTTP (port 80) and HTTPS (port 443) for applications

## MicroK8s Configuration

The cluster is configured with:
- MicroK8s version 1.28 (stable channel)
- Essential add-ons enabled:
  - DNS
  - hostpath-storage
  - ingress
  - metrics-server

## Outputs

After applying the Terraform configuration, you'll get:
- Control plane node public and private IP addresses
- Worker node public IP addresses (for multi-node setup)
- Load balancer IP address (for multi-node setup)
- Command to configure kubectl
- Cluster join token (for adding nodes manually)

## ARM Considerations

The cluster uses ARM processors (VM.Standard.A1.Flex), so ensure that your container images are compatible with the ARM architecture (arm64/aarch64). Most popular images are available in multi-arch versions, but it's worth checking before deployment.

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Troubleshooting

- If nodes fail to join the cluster, check the security lists and ensure the join token is correct
- For MicroK8s issues, check the logs with `sudo microk8s logs`
- Verify network connectivity between nodes using `ping` or `telnet`

