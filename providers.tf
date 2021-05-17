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
  }
}

provider "aws" {
}