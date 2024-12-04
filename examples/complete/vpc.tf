# VPC module

locals {
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  vpc_name        = "vpc-${basename(path.cwd)}"
  vpc_cidr        = "172.72.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, var.azs_to_use)
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.16.0"

  name                 = local.vpc_name
  cidr                 = local.vpc_cidr
  azs                  = local.azs
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dhcp_options  = true
}
