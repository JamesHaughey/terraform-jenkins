provider "aws" {
  region  = "eu-west-1"
  profile = "terraform_linux"
}

terraform {
  backend "s3" {
    key = "workspaces/ubuntu-jenkins/terraform.tfstate"

    region  = "eu-west-1"
    profile = "terraform_linux"

    bucket         = "jhaugh-terraform-tfstate"
    dynamodb_table = "jhaugh-terraform-locking"
    encrypt        = true
  }
}

locals {
  project_name = "ubuntu_jenkins"
}

variable "key_name" {
  description = "Local key name to be provided by TF_VAR_key_name"
  type = string
}

data "aws_ami" "jenkins_master" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-jenkins-*"]
  }
  owners = ["587678272550"]
}

data "aws_ami" "jenkins_slave" {
  most_recent = true
  filter {
    name   = "name"
    values = ["jenkins-slave-*"]
  }
  owners = ["587678272550"]
}

resource "aws_security_group" "jenkins" {
  name = local.project_name
}

resource "aws_security_group_rule" "jenkins_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.jenkins.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_http" {
  type              = "ingress"
  security_group_id = aws_security_group.jenkins.id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_egress" {
  type              = "egress"
  security_group_id = aws_security_group.jenkins.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.jenkins_master.id
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  tags = {
    Name      = "jenkins-master"
    CreatedBy = "Terraform"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.jenkins_slave.id
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  tags = {
    Name      = "jenkins-slave"
    CreatedBy = "Terraform"
  }
}

output "ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "ami_name" {
  value = data.aws_ami.jenkins_master.name
}

output "slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "key_name" {
  value = var.key_name
}

output "project_name" {
  value = local.project_name
}
