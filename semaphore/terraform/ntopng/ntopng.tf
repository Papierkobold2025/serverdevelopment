resource "proxmox_virtual_environment_vm" "ntopng_vm" {
  description = "Managed by Terraform"

  node_name = "api-panel" #Has to be identical to the name in Proxmox
  vm_id     = 114 #ID and name have to be unique, as it will fail if it finds a duplicate in the cluster
  name      = "ntopng"

  clone {
    node_name = "hipervisori5"
    vm_id = 109
    full  = true
    datastore_id = "local-zfs"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "local-zfs"

    ip_config {
      ipv4 {
        address = "192.168.1.158/24" #IP address of the new VM
        gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)
      ]
      password = random_password.ubuntu_vm_password.result
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 50
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 8192
  }

  operating_system {
    type = "l26"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }

  backend "local" {
    path = "/var/lib/semaphore/terraform-state/ntopng.tfstate"
  }
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

provider "proxmox" {
  endpoint  = "https://192.168.1.123:8006/" #Hipervisor where the VM will be installed
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent       = false
    username    = "root"
    private_key = var.ssh_key
  }
}
