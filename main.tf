terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance" {
    ami=data.aws_ami.ubuntu.id
    instance_type="t3.micro"
    key_name="user2_deployer-key"
    count=4
    tags = {
        Name="user2-instance-${count.index}",
        role=count.index==0?"user2-lb": (count.index<3?"user2-web":"user2-backend")
    }
}

output "ips"{
      value = aws_instance.instance.*.public_ip
  }
