terraform {
    required_version = ">= 1.5"

    required_providers {
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 3.2"
      }
      helm = {
        source  = "hashicorp/helm"
        version = "~> 3.3"
      }
    }
  }

  provider "kubernetes" {
    config_path = var.kubeconfig_path
  }

  provider "helm" {
    kubernetes = {
      config_path = var.kubeconfig_path
    }
  }