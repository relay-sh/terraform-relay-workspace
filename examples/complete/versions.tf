terraform {
  required_version = ">= 1.7"

  required_providers {
    relay = {
      source  = "relay-sh/relay"
      version = "~> 0.0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
