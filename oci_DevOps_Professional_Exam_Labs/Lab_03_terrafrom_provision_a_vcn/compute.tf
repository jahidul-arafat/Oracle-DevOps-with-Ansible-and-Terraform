# Launch instances in the Public and Private Subnets of the new VCN
# Launching Public Instance
# And Installing Nginx into it
resource "oci_core_instance" "dummy-tf-instance-pub" {
    # Fetch the AD name "oAOj:AP-MUMBAI-1-AD-1"
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
    compartment_id      = var.compartment_ocid
    shape               = var.image_shape

    create_vnic_details {
        subnet_id = oci_core_subnet.dummy-terraform-subnet-pub.id
        assign_public_ip = "True"
    }

    # Images details
    source_details {
        source_type   = "image"
        source_id = var.image_id
    }

    # SSH Key and install an nginx server into the public instance
    metadata = {
        ssh_authorized_keys = chomp(file(var.ssh_public_key))
        #user_data = base64encode(var.user_data_file_location.rendered)
    }
}
