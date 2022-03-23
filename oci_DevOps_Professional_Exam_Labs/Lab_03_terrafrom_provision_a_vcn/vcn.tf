# Step-2: VCN Setup in Oracle Cloud Infrastructure
# 2.1 Create a new VCN
resource "oci_core_virtual_network" "dummy-terraform-vcn" {
    compartment_id = var.compartment_ocid
    cidr_block = var.vcn_ocid_block
    display_name = var.vcn_display_name
    dns_label = var.vcn_dns_label
}

# 2.2 Creating Gateways
# 2.2.1 Create a new Internet Gateway
resource "oci_core_internet_gateway" "dummy-terraform-igw" {
    compartment_id  = var.compartment_ocid
    vcn_id          = oci_core_virtual_network.dummy-terraform-vcn.id
    display_name    = var.vcn_igw_display_name
}

# 2.2.2 Create a NAT Gateway
resource "oci_core_nat_gateway" "dummy-terraform-ngw" {
    compartment_id  = var.compartment_ocid
    vcn_id          = oci_core_virtual_network.dummy-terraform-vcn.id
    display_name    = var.vcn_ngw_display_name
}

# 2.3 Creating 2x Route Tables
# 2.3.1 Create a new Public Route table
# and add IG into it for public internet access
resource "oci_core_route_table" "dummy-terraform-rt-pub" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.dummy-terraform-vcn.id
    display_name = var.vcn_rt_pub_display_name
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.dummy-terraform-igw.id
    }
}

# 2.3.2 Creating a new Private Route Table
# and associate NGW into it so that private instances can ingress to internet for necessary updates
resource "oci_core_route_table" "dummy-terraform-rt-pvt" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.dummy-terraform-vcn.id
    display_name = var.vcn_rt_pvt_display_name
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = oci_core_nat_gateway.dummy-terraform-ngw.id
    }
}

# 2.4 Creating Public Subnet Security List
resource "oci_core_security_list" "securitylist_pub" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.dummy-terraform-vcn.id
    display_name = "SL_public"

    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }

    ingress_security_rules {
        protocol = "6"  # 6-> TCP
        source   = "0.0.0.0/0"
        tcp_options {
            min = 80
            max = 80
        }
    }
    ingress_security_rules {
        protocol = "6"
        source   = "0.0.0.0/0"
        tcp_options {
            min = 22
            max = 22
        }
    }

    ingress_security_rules {
        protocol = "6"
        source   = "0.0.0.0/0"
        tcp_options {
            min = 443
            max = 443
        }
    }
}


# 2.4 Creating 2x Subnets
# Hence in my current region ap-mumbai-1, there is only one AD, so we will launch both subnets in the same AD
# Standard Practice: To launch Subnets in different ADs

# 2.4.1 Create a public subnet in Availability Domain 1 in the new VCN
resource "oci_core_subnet" "dummy-terraform-subnet-pub" {
    cidr_block     = var.subnet_public_cidr_block
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.dummy-terraform-vcn.id

    # Fetch the availability domain name
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"

    display_name = var.subnet_public_display_name
    dns_label = var.subnet_public_dns_label
    route_table_id = oci_core_route_table.dummy-terraform-rt-pub.id
    security_list_ids = [oci_core_security_list.securitylist_pub.id]

    dhcp_options_id = oci_core_virtual_network.dummy-terraform-vcn.default_dhcp_options_id
}

# 2.4.2 Create a Private Subnet in AD1 in the new VCN
resource "oci_core_subnet" "dummy-terraform-subnet-pvt" {
    cidr_block     = var.subnet_private_cidr_block
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.dummy-terraform-vcn.id

    # Fetch the availability domain name
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"

    display_name = var.subnet_private_display_name
    dns_label = var.subnet_private_dns_label
    route_table_id = oci_core_route_table.dummy-terraform-rt-pvt.id
    dhcp_options_id = oci_core_virtual_network.dummy-terraform-vcn.default_dhcp_options_id
}
