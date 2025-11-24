# terraform-iac/outputs.tf (განახლებული ვერსია)
output "aws_instance_public_ip" {
  description = "Public IP of the created AWS EC2 instance"
  value       = aws_instance.devops_droplet.public_ip
}






#output "nginx_load_balancer_ip" {
#  description = "The external IP address of the Nginx Load Balancer service."
#  value       = kubernetes_service.nginx_loadbalancer.status[0].load_balancer[0].ingress[0].ip
#}

# შეგიძლია ძველი kube_config-ის Output-იც დატოვო, თუმცა ის Sensitive-ია და ლოგებში არ გამოჩნდება.
#output "kube_config" {
#  value     = digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.raw_config
#  sensitive = true
#}
