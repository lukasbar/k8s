# VCN and Network Configuration
resource "oci_core_vcn" "k8s_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-vcn"
}

resource "oci_core_subnet" "k8s_subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.k8s_vcn.id
  display_name      = "${var.cluster_name}-subnet"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_internet_gateway" "k8s_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "${var.cluster_name}-igw"
}

resource "oci_core_route_table" "k8s_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "${var.cluster_name}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k8s_igw.id
  }
}

resource "oci_core_security_list" "k8s_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "${var.cluster_name}-security-list"

  ingress_security_rules {
    protocol    = "6"
    source      = var.your_ip
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.your_ip
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.subnet_cidr
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.subnet_cidr
    tcp_options {
      min = 2379
      max = 2380
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.subnet_cidr
    tcp_options {
      min = 10250
      max = 10250
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Load Balancer for multi-node setup
resource "oci_network_load_balancer" "k8s_nlb" {
  count = var.node_count > 1 ? 1 : 0
  
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-nlb"
  subnet_id      = oci_core_subnet.k8s_subnet.id

  is_private = false
}

resource "oci_network_load_balancer_backend_set" "k8s_nlb_backend_set" {
  count = var.node_count > 1 ? 1 : 0
  
  name                     = "${var.cluster_name}-backend-set"
  network_load_balancer_id = oci_network_load_balancer.k8s_nlb[0].id
  port                     = 6443
  policy                   = "FIVE_TUPLE"
}

# Compute Instances
resource "oci_core_instance" "k8s_nodes" {
  count               = var.node_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "${var.cluster_name}-node-${count.index + 1}"
  shape               = var.node_shape

  shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k8s_subnet.id
    security_list_ids = [oci_core_security_list.k8s_security_list.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.arm_images.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }

  # Install MicroK8s and configure the node
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y snapd",
      "sudo snap install microk8s --classic --channel=1.28/stable",
      "sudo usermod -a -G microk8s ubuntu",
      "sudo chown -R ubuntu:ubuntu ~/.kube",
      "mkdir -p ~/.kube",
      "sudo microk8s config > ~/.kube/config",
      "sudo chown -R ubuntu:ubuntu ~/.kube/config"
    ]
  }

  # Additional configuration for the first node (control plane)
  provisioner "remote-exec" {
    count = count.index == 0 ? 1 : 0
    
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo microk8s enable dns hostpath-storage ingress metrics-server",
      "sudo microk8s status --wait-ready"
    ]
  }

  # Join additional nodes to the cluster
  provisioner "remote-exec" {
    count = count.index > 0 ? 1 : 0
    
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo microk8s join ${oci_core_instance.k8s_nodes[0].private_ip}:25000/${random_string.cluster_token.result}"
    ]
  }
}

# Generate a random token for cluster joining
resource "random_string" "cluster_token" {
  length  = 32
  special = false
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "arm_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  architecture            = "ARM"
  sort_by                 = "TIMECREATED"
  sort_order              = "DESC"
  state                   = "AVAILABLE"
} 
