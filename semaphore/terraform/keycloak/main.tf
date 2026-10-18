resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Terraform"

  node_name = "panel"
  vm_id     = 108

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "keycloak"
    dns {
      servers = ["192.168.X.X"]
    }

    ip_config {
      ipv4 {
        address = "192.168.X.X/24"
        gateway = "192.168.X.X"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = var.keycloak_password
    }
  }

  network_interface {
    name = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 30
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4000
  }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "ubuntu"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = var.keycloak_password
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }

  backend "local" {
    path = "/var/lib/semaphore/terraform-state/keycloak.tfstate"
  }
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "keycloak_password" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

provider "proxmox" {
  endpoint  = "https://192.168.X.X:8006/"
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent       = false
    username    = "root"
    private_key = var.ssh_key
  }
}
