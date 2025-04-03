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

# OKE Cluster
resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.k8s_vcn.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.k8s_subnet.id]
    
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled              = false
    }
  }
}

# Node Pool
resource "oci_containerengine_node_pool" "k8s_node_pool" {
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-node-pool"
  node_shape         = var.node_shape

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id          = oci_core_subnet.k8s_subnet.id
    }
    size = var.node_count
  }

  node_shape_config {
    memory_in_gbs = var.node_memory_in_gbs
    ocpus         = var.node_ocpus
  }

  node_source_details {
    image_id    = data.oci_core_images.arm_images.images[0].id
    source_type = "IMAGE"
  }

  ssh_public_key = file(var.ssh_public_key)
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "arm_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  architecture            = "ARM"
  sort_by                 = "TIMECREATED"
  sort_order              = "DESC"
  state                   = "AVAILABLE"
} 
