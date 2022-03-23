variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "ssh_public_key" {}
variable "region" {}
variable "AD" {
    default = 1
}

# VCN Related Informations
variable "vcn_ocid_block" {
    default = "20.0.0.0/16"
}
variable "vcn_display_name" {
    default = "dummy-terraform-vcn"
}

variable "vcn_dns_label" {
    default = "dummytfmvcn" # 1-15 char long
}

# Gateways
# Internet Gateway
variable "vcn_igw_display_name" {
    default = "dummy-terraform-igw"
}
# NAT Gateway
variable "vcn_ngw_display_name" {
    default = "dummy-terraform-ngw"
}

# Route Tables
# Public Route Table
variable "vcn_rt_pub_display_name" {
    default = "dummy-terraform-rt-pub"
}
variable "vcn_rt_pvt_display_name" {
    default = "dummy-terraform-rt-pvt"
}

# Subnets
# Public Subnet
# Public Subnet CIDR Block
variable "subnet_public_cidr_block" {
    default = "20.0.1.0/24" # Public
}
variable "subnet_public_display_name" {
    default = "dummy-terraform-subnet-public"
}
variable "subnet_public_dns_label" {
    default = "dummytfsuppub" # 1-15 char long
}

# Private Subnet
# Private Subnet CIDR Block
variable "subnet_private_cidr_block" {
    default = "20.0.2.0/24" # Private
}
variable "subnet_private_display_name" {
    default = "dummy-terraform-subnet-private"
}
variable "subnet_private_dns_label" {
    default = "dummytfsubpvt"   # 1-15 char long
}

# image
variable "image_id" {}
variable "image_shape" {}
variable "user_data_file_location" {
    default = "./files/user_data.tpl"
}

