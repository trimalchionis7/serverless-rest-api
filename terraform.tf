terraform {

  cloud {
    organization = "aws-bootcamp-nf"

    workspaces {
      name = "serverless-rest-api"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
  required_version = "~> 1.2"
}