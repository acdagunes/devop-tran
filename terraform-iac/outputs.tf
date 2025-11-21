# outputs.tf

# 1. Droplet-ის IP მისამართის გამოტანა
output "web_droplet_ip" {
  # იღებს IP მისამართს Droplet-ის რესურსიდან
  value = digitalocean_droplet.web_droplet.ipv4_address
  description = "The public IP address of the web Droplet for SSH access."
}

# 2. Ansible Inventory-სთვის გამოსატანი ჰოსტის სია
output "ansible_inventory_host" {
  value = [digitalocean_droplet.web_droplet.ipv4_address]
  description = "Host list formatted for simple Ansible inventory."
}
