terraform {
    required_version = ">=0.13.1"
    required_providers {
      aws = ">=3.54.0"
      local = ">=2.1.0"
    }
    backend "s3" {
      bucket = "myfcbucket"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
}

provider "aws" {
  region = "us-east-1"
}

module "mod_vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
}

module "mod_eks" {
  source = "./modules/eks"
  prefix = var.prefix
  my_vpc_id = module.mod_vpc.my_vpc_id
  cluster_name = var.cluster_name
  log_retention_days = var.log_retention_days
  my_subnet_ids = module.mod_vpc.my_subnet_ids
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
}
