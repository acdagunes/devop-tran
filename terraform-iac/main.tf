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

# 3. SSH გასაღების მონაცემების მოზიდვა (იყენებს ახალ პროვაიდერს)
data "digitalocean_ssh_key" "my_ssh_key" {
  name = "Nikoloz_Local_Machine"
}

# 4. Droplet-ის შექმნა (IaC-ის მთავარი ნაწილი!)
# terraform-iac/main.tf

resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "ansible-compose-k8s-cluster"
  region  = "fra1"
  version = "1.28" # ან შენი სასურველი ვერსია

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb" # 2GB RAM / 1 vCPU
    node_count = 1
  }
}  
  # SSH გასაღების მიბმა Droplet-ზე
  ssh_keys = [
    data.digitalocean_ssh_key.my_ssh_key.id
  ]
}
