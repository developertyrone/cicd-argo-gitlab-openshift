terraform {
  required_providers {
    ignition = {
      source = "terraform-providers/ignition"
      version = "~> 1.2.1"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">= 0.13"
}
