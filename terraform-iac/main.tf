# terraform-iac/main.tf (სუფთა AWS კონფიგურაცია)

    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    # 2. AWS Provider-ის კონფიგურაცია
    # იყენებს ცვლადებს, რომლებიც მოწოდებულია GitHub Actions-ის env-დან.
    provider "aws" {
      region     = var.region
      access_key = var.aws_access_key
      secret_key = var.aws_secret_key
    }

    # --- ახალი ნაწილი: SSH Key Pair-ის ინტეგრაცია ---

    # 3. ლოკალური Public Key-ის შიგთავსის წაკითხვა
    data "local_file" "ssh_public_key" {
      filename = "ssh-key.pub"
    }

    # 4. AWS Key Pair-ის შექმნა წაკითხული Public Key-ით
    resource "aws_key_pair" "ssh_key" {
      key_name   = "devops-ansible-key"
      public_key = data.local_file.ssh_public_key.content
    }

    # 5. AWS VPC (Virtual Private Cloud) - ქსელური საზღვარი
    resource "aws_vpc" "vpc" {
      cidr_block           = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags = {
        Name = "${var.cluster_name}-vpc"
      }
    }

    # 6. AWS Subnet (ქვექსელი) - სადაც ინსტანსი გაეშვება
    resource "aws_subnet" "public_subnet" {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true # საჯარო IP მისამართის მინიჭება
      availability_zone       = "${var.region}a" # მაგ: eu-central-1a
      tags = {
        Name = "${var.cluster_name}-public-subnet"
      }
    }

    # 7. უსაფრთხოების ჯგუფი (Security Group) - ფაიერვოლი SSH-ისთვის
    resource "aws_security_group" "ssh_access" {
      name        = "devops-ssh-access-sg"
      description = "Allow SSH inbound traffic for DevOps testing"
      vpc_id      = aws_vpc.vpc.id

      # Ingress rule: SSH (Port 22) World-Wide
      ingress {
        description = "SSH Access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # ნებართვა ნებისმიერი IP-დან
      }

      # Egress rule: Allow all outbound traffic
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" # ყველა პროტოკოლი
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "${var.cluster_name}-ssh-sg"
      }
    }

    # 8. EC2 ინსტანსისთვის AMI-ის (Image) მოძებნა
    data "aws_ami" "ubuntu" {
      most_recent = true
      filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      }
      filter {
        name   = "virtualization-type"
        values = ["hvm"]
      }
      owners = ["099720109477"] # Canonical AMI owner ID
    }

    # 9. EC2 ინსტანსის შექმნა (Droplet-ის ანალოგი)
    resource "aws_instance" "devops_droplet" {
      ami             = data.aws_ami.ubuntu.id
      instance_type   = "t3.micro" # Free Tier ინსტანსი
      subnet_id       = aws_subnet.public_subnet.id
      associate_public_ip_address = true
      
      # დავუმატეთ ახალი უსაფრთხოების ჯგუფი
      vpc_security_group_ids = [aws_security_group.ssh_access.id] 
      
      # კრიტიკული ნაწილი: EC2-ს ვუერთებთ Key Pair-ს
      key_name               = aws_key_pair.ssh_key.key_name

      tags = {
        Name = "DevOps-EC2-Test-Instance"
      }
    }

    # --- EC2-ის IP მისამართის გამოტანა ---
    output "instance_public_ip" {
      description = "EC2 ინსტანსის საჯარო IP მისამართი"
      value       = aws_instance.devops_droplet.public_ip
    }