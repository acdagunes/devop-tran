# main.tf (DigitalOcean-ის რესურსები)

# terraform-iac/main.tf (განახლებული)

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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
 

