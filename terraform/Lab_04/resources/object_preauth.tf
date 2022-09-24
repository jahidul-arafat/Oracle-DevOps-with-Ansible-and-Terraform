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
resource "oci_objectstorage_bucket" "terraform-bucket-preauth" {
    compartment_id = var.compartment_ocid
    namespace = var.namespace
    name = "tf-example-bucket-preauth"
    access_type = "NoPublicAccess"
}

#Ref: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/objectstorage_preauthrequest
# oci os bucket list --compartment-id $compartment_id
resource "oci_objectstorage_preauthrequest" "terraform-preauth-request" {
    access_type = "AnyObjectWrite"
    bucket = oci_objectstorage_bucket.terraform-bucket-preauth.name
    name = "terraform-preauth"
    namespace = var.namespace
    time_expires = "2022-01-26T12:42:18.143000+00:00"
}

