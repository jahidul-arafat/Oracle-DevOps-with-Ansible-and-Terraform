# Print the VCN ID
output "vcn-id" {
    value = oci_core_virtual_network.terraform-vcn.id
}

output "subnet-id" {
    value = oci_core_subnet.terraform-public-subnet1.id 
}