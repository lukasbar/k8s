variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the key"
  type        = string
}

variable "region" {
  description = "The Oracle Cloud region"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k8s-cluster"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use"
  type        = string
  default     = "v1.28.2"
}

variable "node_count" {
  description = "Number of nodes in the cluster (1-2 for Always Free tier)"
  type        = number
  default     = 1
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 2
    error_message = "Node count must be between 1 and 2 for Always Free tier."
  }
}

variable "node_shape" {
  description = "The shape of the node instances"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_ocpus" {
  description = "Number of OCPUs for each node (1-4 for Always Free tier)"
  type        = number
  default     = 1
  validation {
    condition     = var.node_ocpus >= 1 && var.node_ocpus <= 4
    error_message = "OCPUs must be between 1 and 4 for Always Free tier."
  }
}

variable "node_memory_in_gbs" {
  description = "Amount of memory in GBs for each node (6-24 for Always Free tier)"
  type        = number
  default     = 6
  validation {
    condition     = var.node_memory_in_gbs >= 6 && var.node_memory_in_gbs <= 24
    error_message = "Memory must be between 6 and 24 GB for Always Free tier."
  }
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "your_ip" {
  description = "Your IP address for SSH and Kubernetes API access"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to your SSH public key file"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to your SSH private key file"
  type        = string
} 
