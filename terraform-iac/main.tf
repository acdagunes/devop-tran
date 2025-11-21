# main.tf (DigitalOcean-ის რესურსები)

# 1. Terraform-ის მოთხოვნები (DigitalOcean Provider-ის დამატება)
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# 2. DigitalOcean Provider-ის კონფიგურაცია
# პროვაიდერი ავტომატურად გამოიყენებს DIGITALOCEAN_TOKEN გარემო ცვლადს
provider "digitalocean" {}

# 3. SSH გასაღების მონაცემების მოზიდვა (თუ უკვე გაქვს ატვირთული DO-ზე)
data "digitalocean_ssh_key" "my_ssh_key" {
  # !!! ჩაანაცვლე "ssh-key-name" შენი DigitalOcean-ზე ატვირთული SSH გასაღების ზუსტი სახელით!
  name = "Nikoloz_Local_Machine"
}

# 4. Droplet-ის შექმნა (IaC-ის მთავარი ნაწილი!)
resource "digitalocean_droplet" "web_droplet" {
  image  = "ubuntu-22-04-x64" # Ubuntu-ს სტაბილური ვერსია
  name   = "ansible-compose-web-server"
  region = "fra1" # მაგალითად, ფრანკფურტი (შეგიძლია შეცვალო)
  size   = "s-1vcpu-1gb" # მინიმალური ზომა
  
  # SSH გასაღების მიბმა Droplet-ზე
  ssh_keys = [
    data.digitalocean_ssh_key.my_ssh_key.id
  ]
}
