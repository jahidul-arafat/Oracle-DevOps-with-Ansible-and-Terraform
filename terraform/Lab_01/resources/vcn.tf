# Lab -01: Create an OCI Simple VCN Using Terraform
# Enlist the information of the provider.
# Here, in pur case, the provider is Oracle Cloud Infrastructure
# So, you have to enlist the following informations
/*
    - oci version
    - tenancy ocid
    - user ocid
    - fingerprint of the API Key of the user
    - path to the private key
    - region
*/
provider "oci" {
    tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaukvw5677joefjfaygfjxcwjnbqbr4m3hmp2ytnln2fucluumedca"
    user_ocid = "ocid1.user.oc1..aaaaaaaandyodgpuw2cc6vty6qwxxnk6ba5xfuxp36pi4yurugqdtubzue6q"
    fingerprint = "9f:10:ec:7b:56:cc:00:2d:a3:14:d2:4b:1b:67:47:c8"
    private_key_path = "/home/opc/.oci/oci_api_key.pem"
    region = "us-ashburn-1"
}

# Create a dummy virtual cloud network named "simple-vcn"
# use the oci terraform resoruce: oci_core_vcn
# To create a dummy vcn it requires the followign informations:
/*
    - cird block
    - dns label
    - to which compartment the vcn sould be created: compartment ocid
    - vcn display name: optional
*/
resource "oci_core_vcn" "simple-vcn" {
    cidr_block = "20.0.0.0/16"
    dns_label = "vcn1"
    compartment_id = "ocid1.compartment.oc1..aaaaaaaae5qhsooxnfedbsbmohy5cibfg7fnyysxhodbrnva53wqaqf3z5aa"
    display_name = "simple-vcn"
}

# Print the VCN ID
output "vcnid" {
    value = oci_core_vcn.simple-vcn.id
}

/*
What is the Drawback of this deployment architecture?
- Here we have included all the required components' OCID directly into the template, which is not a recommended practice

Solution:
- Use environment varibales to store the dta separately and call them in the main Terraform template.
*/