terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "WhiteAway-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "${terraform.workspace}"
  }
}


module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-fargate-${terraform.workspace}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "${terraform.workspace}"
    Project     = "WhiteAway"
  }
}

resource "aws_security_group" "this" {
  name        = "hello_world-${terraform.workspace}"
  description = "Allow ALL traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "hello_world" {
  source = "./service-hello-world"

  vpc_id = module.vpc.vpc_id
  subnets_ids = module.vpc.public_subnets
  cluster_id = module.ecs.cluster_id
  sg_id = aws_security_group.this.id
}