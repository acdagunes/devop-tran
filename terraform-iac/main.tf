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
variable "do_token" {
  description = "DigitalOcean API Token from GitHub Secrets"
  type        = string
  sensitive   = true # უზრუნველყოფს, რომ არ გამოჩნდეს ლოგებში
}

# 2. DigitalOcean Provider-ის კონფიგურაცია
# ახლა Token-ს ექსპლიციტურად გადავცემთ ცვლადის მეშვეობით
provider "digitalocean" {
  token = var.do_token 
}
provider "aws" {
  region     = var.region # იყენებს var.region-ს
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# 3. Kubernetes Provider-ის კონფიგურაცია
provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  # ეს data ბლოკი გვჭირდება kube_config-ის მისაღებად
  token                  = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].token 
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].cluster_ca_certificate)
}






# 4. Droplet-ის შექმნა (IaC-ის მთავარი ნაწილი!)
# terraform-iac/main.tf
data "digitalocean_kubernetes_versions" "latest" {
  version_prefix = "1." # მოძებნე ნებისმიერი 1.x ვერსია
}
resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "ansible-compose-k8s-cluster"
  region  = "fra1"
  version = data.digitalocean_kubernetes_versions.latest.latest_version

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb" # 2GB RAM / 1 vCPU
    node_count = 1
  }
}  
 
# terraform-iac/main.tf (დაამატე ეს ბლოკი)

resource "kubernetes_service" "nginx_loadbalancer" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      app = "nginx-web"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
  # უზრუნველყოფს, რომ ეს მხოლოდ კლასტერის შექმნის შემდეგ გაეშვება
  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster] 
}
# terraform-iac/main.tf (დაამატე ეს ბლოკი)

resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name = "nginx-deployment"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx-web"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-web"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
   
}
data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = digitalocean_kubernetes_cluster.k8s_cluster.name
  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster] 
}
