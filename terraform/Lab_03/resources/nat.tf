# Lab 03: Creation of Public and Private Subnet along with NAT Gateway
# The purpose of NAT Gateway is to get internet access when you launch instances in a private subnet
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
    compartment_id = "${var.compartment_ocid}" # this will return a list of all ADs, which can be accessed by AD[0], AD[1] or AD[2]
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

# Create a new NAT Gateway
resource "oci_core_nat_gateway" "terraform-nat-gateway" {
    compartment_id = var.compartment_ocid
    display_name = "terraform-nat-gateway"
    vcn_id = oci_core_virtual_network.terraform-vcn.id
  
}

# Create a new Route Table - Default route Table
resource "oci_core_route_table" "terraform-rt" {
    compartment_id = var.compartment_ocid
    vcn_id=oci_core_virtual_network.terraform-vcn.id
    display_name = "terraform-route-table"
    route_rules {
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.terraform-ig.id
    }
}

# Route Table for Private Subnet
resource "oci_core_route_table" "terraform-rt2" {
    compartment_id = var.compartment_ocid
    vcn_id=oci_core_virtual_network.terraform-vcn.id
    display_name = "terraform-route-table2"
    route_rules {
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.terraform-nat-gateway.id
    }
}

# Create a public subnet 1 in AD1 in the new VCN
resource "oci_core_subnet" "terraform-public-subnet1" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
    cidr_block = "20.0.0.0/24"
    display_name = "terraform-public-subnet1"
    dns_label = "subnet1"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_route_table.terraform-rt.id
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id
}

# Create a private subnet 1 in AD2 in the new VCN
resource "oci_core_subnet" "terraform-private-subnet1" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
    cidr_block = "20.0.1.0/24"
    display_name = "terraform-private-subnet1"
    dns_label = "subnet2"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_route_table.terraform-rt2.id
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id
}



