# Automated Kubernetes Cluster Deployment

This project enables automatic creation and configuration of a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using ARM processors. The entire infrastructure is managed as code using Terraform, and application deployment follows the GitOps methodology.

## Project Overview

The project consists of three main components:
- **Terraform** - for automatic deployment and configuration of infrastructure in Oracle Cloud
- **Kubernetes** - cluster on ARM architecture
- **GitOps** - for managing application deployments

## Prerequisites

- Oracle Cloud account with access to services
- Terraform (version >= 1.0.0)
- OCI CLI configured with appropriate permissions
- kubectl
- Git
- Optional: Flux, ArgoCD, or other GitOps tool


## ARM Considerations

The cluster uses ARM processors, so make sure that your container images are compatible with the ARM architecture (arm64/aarch64). Most popular images are available in multi-arch versions, but it's worth checking before deployment.
