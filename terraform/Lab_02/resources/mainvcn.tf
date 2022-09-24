# Lab 02: Create a VCN alsong with IGW, Rooute Table and Public Subnet
# All OCI Terraform Resource List: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/guides/resource_discovery


# use the varibales defined in terraform.tfvars or bash profile file
# Ref: https://github.com/terraform-providers/terraform-provider-oci/issues/570
variable "tenancy_ocid" {
  
}

variable "user_ocid" {
  
}
 
variable "fingerprint" {
  
}

variable "private_key_path" {
  
}

variable "compartment_ocid" {
  
}

variable "region" {
  
}

variable "AD" {
    default = 1
  
}

# Provider
provider "oci" {
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    private_key_path = var.private_key_path
}

data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.compartment_ocid}" # this will return a list
}

# Create a new VCN
variable "VCN_terraform" {
    default = "20.0.0.0/16" 
}

resource "oci_core_virtual_network" "terraform-vcn" {
    cidr_block = var.VCN_terraform
    compartment_id = var.compartment_ocid
    display_name = "terraform-vcn"
    dns_label = "terraformvcn"
}

# Create a new Internet Gateway
resource "oci_core_internet_gateway" "terraform-ig" {
    compartment_id = var.compartment_ocid
    display_name = "terraform-intenet-gateway"
    vcn_id = oci_core_virtual_network.terraform-vcn.id
}

# Create a new Route Table
resource "oci_core_route_table" "terraform-rt" {
    compartment_id = var.compartment_ocid
    vcn_id=oci_core_virtual_network.terraform-vcn.id
    display_name = "terraform-route-table"
    route_rules {
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      network_entity_id = "${oci_core_internet_gateway.terraform-ig.id}"
    }
}

# Create a public subnet 1 in AD1 in the new VCN
resource "oci_core_subnet" "terraform-public-subnet1" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
    cidr_block = "20.0.1.0/24"
    display_name = "terraform-public-subnet1"
    dns_label = "subnet1"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_route_table.terraform-rt.id
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id
  
}



