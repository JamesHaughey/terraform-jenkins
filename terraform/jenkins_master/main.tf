provider "aws" {
  region  = "eu-west-1"
  profile = "terraform_linux"
}

terraform {
  backend "s3" {
    key = "workspaces/ubuntu-jenkins/terraform.tfstate"

    region  = "eu-west-1"
    profile = "terraform_emr"

    bucket         = "jhaugh-terraform-tfstate"
    dynamodb_table = "jhaugh-terraform-locking"
    encrypt        = true
  }
}

locals {
  project_name = "ubuntu_jenkins"
  key_name     = "linux_desktop_euwst1"
}

data "aws_ami" "ubuntu_jenkins" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-jenkins-*"]
  }
  owners = ["587678272550"]
}

resource "aws_security_group" "ubuntu_jenkins" {
  name = local.project_name
}

resource "aws_security_group_rule" "ubuntu_jenkins_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.ubuntu_jenkins.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ubuntu_jenkins_http" {
  type              = "ingress"
  security_group_id = aws_security_group.ubuntu_jenkins.id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ubuntu-remote_egress" {
  type              = "egress"
  security_group_id = aws_security_group.ubuntu_jenkins.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "ubuntu_jenkins" {
  ami                    = data.aws_ami.ubuntu_jenkins.id
  instance_type          = "t2.medium"
  key_name               = local.key_name
  vpc_security_group_ids = [aws_security_group.ubuntu_jenkins.id]

  tags = {
    Name      = "ubuntu-jenkins"
    CreatedBy = "Terraform"
  }
}

output "ip" {
  value = aws_instance.ubuntu_jenkins.public_ip
}

output "ami_name" {
  value = data.aws_ami.ubuntu_jenkins.name
}

output "key_name" {
  value = local.key_name
}

output "project_name" {
  value = local.project_name
}
