terraform {
  backend "remote" {
    organization = "dresrok"
    workspaces {
      name = "platzi-ec2-jenkins"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.40.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "aws" {
}
