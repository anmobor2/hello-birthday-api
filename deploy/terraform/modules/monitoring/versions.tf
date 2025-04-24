terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.36.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}