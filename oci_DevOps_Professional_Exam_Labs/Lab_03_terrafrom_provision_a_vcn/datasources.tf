#====================================================================================================================
# Step-0.0: for terraform itself which collection/module to use
terraform {
    required_providers {
        oci ={
            source = "hashicorp/oci"
        }
    }
}

# Step-0.1: Setting up the Provider "OCI"
# Provider #OCI
# Loading the information from terraform.tfvars
provider "oci" {
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    private_key_path = var.private_key_path
}

#====================================================================================================================
# Step-1: Pre-requisites
# 1.1 List all availability domain in a given compartment
# We will use this later when creating subnet for our VCN
data "oci_identity_availability_domains" "ADs"{
    compartment_id = var.compartment_ocid
}
