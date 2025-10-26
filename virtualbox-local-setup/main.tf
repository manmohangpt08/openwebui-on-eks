terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "~> 0.3"
    }
  }
}

provider "virtualbox" {}

resource "virtualbox_vm" "k8s_vm" {
  name   = "local-k8s"
  image  = "generic/ubuntu2204"
  cpus   = 2
  memory = 4096
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
  ssh_username = "vagrant"
  ssh_password = "vagrant"
}
