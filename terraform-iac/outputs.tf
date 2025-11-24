# outputs.tf

# terraform-iac/outputs.tf

output "kube_config" {
  value     = digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.raw_config
  sensitive = true
}
