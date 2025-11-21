# 🚀 Fully Automated DigitalOcean Web Deployment (IaC & Configuration Management)

## 🌟 Project Overview

This project demonstrates a robust, repeatable, and idempotent infrastructure pipeline using **Terraform** and **Ansible**. The goal is to provision a cloud server (Droplet) on DigitalOcean and automatically deploy an Nginx web service using Docker Compose.

This solution proves expertise in:
* **Infrastructure as Code (IaC):** Managing cloud resources (Droplets, SSH Keys) with Terraform.
* **Configuration Management (CM):** Idempotently configuring the remote server using Ansible.
* **Container Orchestration:** Deploying applications (Nginx) via Docker Compose.
* **DevOps Best Practices:** Using clean Git workflow and separating configuration from infrastructure.

## 🛠️ Technology Stack

| Component | Tool | Purpose |
| :--- | :--- | :--- |
| **Cloud** | DigitalOcean | Hosting the web server (Droplet). |
| **IaC** | Terraform | Provisioning the Droplet and managing its lifecycle. |
| **CM** | Ansible | Installing Docker, copying configuration, and executing deployment. |
| **Containerization** | Docker / Docker Compose | Running Nginx web service on port **8082**. |
| **OS** | Ubuntu 22.04 LTS | Droplet operating system. |

---

## 🏗️ Deployment Steps (How to Run This Project)

Follow these steps to fully deploy the Nginx web server on a new Droplet using the provided configuration.

### Prerequisites

1.  **Terraform:** Must be installed locally.
2.  **Ansible:** Must be installed locally.
3.  **DigitalOcean Access:** A Personal Access Token (PAT) must be set as an environment variable:
    ```bash
    export DIGITALOCEAN_TOKEN="your_do_token"
    ```
4.  **SSH Key:** Your SSH public key must be uploaded to DigitalOcean, and the private key path must be correct in the Ansible inventory.

### Step 1: Provision Infrastructure (Terraform)

Navigate to the `terraform-iac` directory to provision the Droplet.

```bash
cd terraform-iac
terraform init
terraform apply -auto-approve
