# Lab 04: Object Storage: Creating of a New Bucket
# For Bucket creation, you have to specify the "namespace". Namespace is same as the "tenancy".

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

# define the namespace variable
variable "namespace" {
    default="ocuocictrng13"
  
}

# Provider
provider "oci" {
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    private_key_path = var.private_key_path
}

# Creation of a new bucket
resource "oci_objectstorage_bucket" "terraform-bucket" {
    compartment_id = var.compartment_ocid
    namespace = var.namespace
    name = "tf-example-bucket"
    access_type = "NoPublicAccess"
}

