# terraform-iac/variables.tf

# 1. DigitalOcean Token (ჩვენი ძველი)
variable "do_token" {
  description = "DigitalOcean API Token from GitHub Secrets"
  type        = string
  sensitive   = true 
  default     = "" # default-ი სჭირდება apply-სთვის
}

# 2. AWS კრედენციალები (კრიტიკულია!)
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
  default     = "" 
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = ""
}

# 3. საერთო კონფიგურაციები
variable "region" {
  description = "Cloud Region for resource creation"
  type        = string
  default     = "eu-central-1" # AWS Frankfurt-ის რეგიონი
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster (used for tagging)"
  type        = string
  default     = "ansible-compose-k8s-cluster"
}


