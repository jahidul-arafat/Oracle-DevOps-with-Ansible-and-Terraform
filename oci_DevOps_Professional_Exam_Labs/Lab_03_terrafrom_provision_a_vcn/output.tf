# Print the VCN ID
output "dummy-tf-vcn-id" {
  value = oci_core_virtual_network.dummy-terraform-vcn.id
}

output "dummy-tf-subnet-id" {
  value = oci_core_subnet.dummy-terraform-subnet-pub.id
}

output "dummy-tf-instance-pub-id" {
  value = oci_core_instance.dummy-tf-instance-pub.id
}

output "dummy-tf-instance-pub-public-ip" {
  value = oci_core_instance.dummy-tf-instance-pub.public_ip
}
