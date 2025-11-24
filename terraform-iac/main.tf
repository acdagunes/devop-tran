# main.tf (DigitalOcean-ის რესურსები)

# terraform-iac/main.tf (განახლებული)

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = { # ❗️ ეს აკლია
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    aws = { 
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}

# დაამატე ცვლადი, რომელიც მიიღებს Token-ს GitHub Actions-დან
#variable "do_token" {
#  description = "DigitalOcean API Token from GitHub Secrets"
#  type        = string
#  sensitive   = true # უზრუნველყოფს, რომ არ გამოჩნდეს ლოგებში
#}

# 2. DigitalOcean Provider-ის კონფიგურაცია
# ახლა Token-ს ექსპლიციტურად გადავცემთ ცვლადის მეშვეობით
#provider "digitalocean" {
#  token = var.do_token 
#}
provider "aws" {
  region     = var.region # იყენებს var.region-ს
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# 3. Kubernetes Provider-ის კონფიგურაცია
#provider "kubernetes" {
#  host                   = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  # ეს data ბლოკი გვჭირდება kube_config-ის მისაღებად
#  token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].token 
#  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].cluster_ca_certificate)
#}


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

# 7. EC2 ინსტანსის შექმნა (Droplet-ის ანალოგი)
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

resource "aws_instance" "devops_droplet" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Free Tier ინსტანსი
  subnet_id     = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "DevOps-EC2-Test-Instance"
  }
}



# 4. Droplet-ის შექმნა (IaC-ის მთავარი ნაწილი!)
# terraform-iac/main.tf
#data "digitalocean_kubernetes_versions" "latest" {
#  version_prefix = "1." # მოძებნე ნებისმიერი 1.x ვერსია
#
#resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
#  name    = "ansible-compose-k8s-cluster"
#  region  = "fra1"
#  version = data.digitalocean_kubernetes_versions.latest.latest_version

#  node_pool {
#    name       = "worker-pool"
#    size       = "s-1vcpu-2gb" # 2GB RAM / 1 vCPU
#    node_count = 1
#  }
#}  
 
# terraform-iac/main.tf (დაამატე ეს ბლოკი)


  # უზრუნველყოფს, რომ ეს მხოლოდ კლასტერის შექმნის შემდეგ გაეშვება
#  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster] 
#}
# terraform-iac/main.tf (დაამატე ეს ბლოკი)


#data "digitalocean_kubernetes_cluster" "k8s_cluster" {
#  name = digitalocean_kubernetes_cluster.k8s_cluster.name
#  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster] 
#}
