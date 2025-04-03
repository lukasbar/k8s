# Free Kubernetes Cluster on Oracle Cloud Infrastructure

This project enables automatic creation and configuration of a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using ARM processors within the Always Free tier. The entire infrastructure is managed as code using Terraform, and the cluster is deployed using Oracle Container Engine for Kubernetes (OKE).

## Always Free Tier Limitations

The configuration is optimized for Oracle's Always Free tier, which includes:
- Up to 2 VM.Standard.A1.Flex instances
- Each instance can have:
  - 1-4 OCPUs
  - 6-24 GB of memory
- Free block storage
- Free VCN and networking resources
- Free load balancer

## Project Overview

The project consists of the following components:
- **Terraform** - for automatic deployment and configuration of infrastructure in Oracle Cloud
- **OKE (Oracle Container Engine for Kubernetes)** - managed Kubernetes service
- **Network Configuration** - properly configured VCN and security lists
- **Node Pools** - ARM-based worker nodes within Always Free tier limits

## Features

- Deploy a managed Kubernetes cluster using OKE within Always Free tier
- Use ARM-based VM.Standard.A1.Flex instances
- Automatic cluster configuration and management
- Pre-configured security rules for cluster communication
- Built-in load balancing for services
- Automatic updates and maintenance
- Integrated monitoring and logging

## Prerequisites

- Oracle Cloud account with access to Always Free tier services
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
- Sufficient Always Free tier limits

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
   kubernetes_version = "v1.28.2"
   node_count       = 1  # Set to 1 or 2 for Always Free tier
   node_shape       = "VM.Standard.A1.Flex"
   node_ocpus       = 1  # 1-4 OCPUs per node
   node_memory_in_gbs = 6  # 6-24 GB per node

   # Network Configuration
   vcn_cidr         = "10.0.0.0/16"
   subnet_cidr      = "10.0.1.0/24"
   your_ip          = "YOUR_IP_ADDRESS/32"  # Your IP address with CIDR notation

   # SSH Configuration
   ssh_public_key   = "~/.ssh/id_rsa.pub"
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

### Node Configuration
- ARM-based instances (VM.Standard.A1.Flex)
- Configurable number of nodes (1-2 for Always Free tier)
- Each node with:
  - 1-4 OCPUs
  - 6-24 GB memory
- Oracle Linux 8 as the base image

### Network Configuration
The infrastructure includes:
- VCN with a public subnet
- Internet Gateway for external access
- Security lists with rules for:
  - SSH access (port 22) from your IP
  - Kubernetes API (port 6443) from your IP and cluster nodes
  - etcd communication (ports 2379-2380) between nodes
  - kubelet communication (port 10250) between nodes
  - HTTP (port 80) and HTTPS (port 443) for applications

## OKE Features

The cluster is configured with:
- Managed control plane
- Automatic updates
- Built-in monitoring
- Integrated logging
- Service load balancing
- Metrics server

## Outputs

After applying the Terraform configuration, you'll get:
- Cluster ID
- Cluster endpoint
- Node pool ID
- Command to configure kubectl
- Cluster name
- Node count and configuration
- Resource allocation details

## ARM Considerations

The cluster uses ARM processors (VM.Standard.A1.Flex), so ensure that your container images are compatible with the ARM architecture (arm64/aarch64). Most popular images are available in multi-arch versions, but it's worth checking before deployment.

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Troubleshooting

- If cluster creation fails, check your Always Free tier limits
- For node pool issues, verify the subnet and security list configurations
- Check OCI Console for detailed error messages
- Ensure your IP address is correctly specified in the security rules
- Monitor your Always Free tier usage in the OCI Console

