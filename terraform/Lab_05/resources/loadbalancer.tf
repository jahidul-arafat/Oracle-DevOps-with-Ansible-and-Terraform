# Lab 05: Create a Public Load Balancer which involves
/*
    - Two instances
    - Two Public subnets
    - Security list with 80 port opened
    - Listeners
    - Back-end sets
    - Path route sets
    - Host names
    - Work Requests
*/

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

variable "ssh_public_key" {
  
}

variable "availability_domain" {
    default = 3
}

variable "instance_image_ocid" {
    default = {
        # https://docs.oracle.com/en-us/iaas/images/image/c918702c-8d3a-4895-a5f5-2e953eac4087/
        # Oracle-provider image "Oracle-Linux-7.9-2021.12.08-0"
        us-phoenix-1="ocid1.image.oc1.phx.aaaaaaaasa57q4lvr6l4eztq3qbzqjrfxhk5tv6lhwvpt2vzbnau3boqarkq"
        us-ashburn-1="ocid1.image.oc1.iad.aaaaaaaaffh3tppq63kph77k3plaaktuxiu43vnz2y5oefkec37kwh7oomea"
        en-frankfurt-1="ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawq2h5g4nb6odpdt3rwyvp7bx26fv5pyjpbwzlwnybztss34vuz2q"
        uk-london-1="ocid1.image.oc1.uk-london-1.aaaaaaaaoy3hj7nha6yi3jj4f2oaeqp44aak6j34sznk3t3gvugis64ixfsa"
    }
}

variable "instance_shape" {
    default = "VM.Standard2.1"  
}


# Provider
provider "oci" {
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    private_key_path = var.private_key_path
}

# getthe list of all availability domains
data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.compartment_ocid}" # this will return a list of all ADs, which can be accessed by AD[0], AD[1] or AD[2]
}

# ------------------------- Create a new VCN --------------------------------------------
variable "VCN_cidr_block" {
    default = "20.0.0.0/16" 
}

resource "oci_core_virtual_network" "terraform-vcn" {
    cidr_block = var.VCN_cidr_block
    compartment_id = var.compartment_ocid
    display_name = "terraform-vcn"
    dns_label = "terraformvcn"
}



#-------------------------- Security Lists: 2x ------------------------------------------
resource "oci_core_security_list" "lb-security-list" {
    display_name = "lb-security-list"
    compartment_id = oci_core_virtual_network.terraform-vcn.compartment_id
    vcn_id = oci_core_virtual_network.terraform-vcn.id

    egress_security_rules {
      protocol = "all"
      destination = "0.0.0.0/0"
    }

    ingress_security_rules {
        protocol = "6" #TCP Protocol
        source = "0.0.0.0/0"
        tcp_options {
            min=80
            max=80
        }
    }

    ingress_security_rules {
        protocol = "6" #TCP Protocol
        source = "0.0.0.0/0"
        tcp_options {
            min=443
            max=443
        }
      
    }
}

resource "oci_core_default_security_list" "default-security-list" {
    manage_default_resource_id = oci_core_virtual_network.terraform-vcn.default_security_list_id

    egress_security_rules {
      protocol = "all"
      destination = "0.0.0.0/0"
    }

    ingress_security_rules {
        protocol = "6" #TCP Protocol
        source = "20.0.0.0/24"
        tcp_options {
            min=80
            max=80
        }
    }

    ingress_security_rules {
        protocol = "6" #TCP Protocol
        source = "20.0.1.0/24"
        tcp_options {
            min=80
            max=80
        }
    }

    ingress_security_rules {
        protocol = "6" #TCP Protocol
        source = "0.0.0.0/0"
        tcp_options {
            min=22
            max=22
        }
    }
}

#------------------ Internet Gateway --------------------------------------------------
# Create a new Internet Gateway
resource "oci_core_internet_gateway" "terraform-ig" {
    compartment_id = var.compartment_ocid
    display_name = "terraform-intenet-gateway"
    vcn_id = oci_core_virtual_network.terraform-vcn.id
}


#------------------- Route Table: 2x ------------------------------------------------------
# Create a new Route Table - Default route Table
resource "oci_core_default_route_table" "default-route-table" {
    manage_default_resource_id = oci_core_virtual_network.terraform-vcn.default_route_table_id
    route_rules {
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.terraform-ig.id
    }
}

# Create a new Route Table - LB Route Table
resource "oci_core_route_table" "lb-route-table" {
    compartment_id = var.compartment_ocid
    vcn_id=oci_core_virtual_network.terraform-vcn.id
    display_name = "terraform-rt-2"
    route_rules {
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.terraform-ig.id
    }
}

#-------------------- Subnet: 2x -----------------------------------------------------------
# Create a public subnet 1 in AD1 in the new VCN
resource "oci_core_subnet" "lb-subnet1" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 3], "name")}"
    cidr_block = "20.0.0.0/24"
    display_name = "lb-subnet-1"
    dns_label = "lbsubnet1"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_route_table.lb-route-table.id
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id

    security_list_ids = [oci_core_security_list.lb-security-list.id]

    provisioner "local-exec" {
        command = "sleep 5"
    
    }
}

# Create a public subnet 2 in AD2 in the new VCN
resource "oci_core_subnet" "lb-subnet2" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 2], "name")}"
    cidr_block = "20.0.1.0/24"
    display_name = "lb-subnet-2"
    dns_label = "lbsubnet2"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_route_table.lb-route-table.id
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id

    security_list_ids = [oci_core_security_list.lb-security-list.id]

    provisioner "local-exec" {
        command = "sleep 5"
    
    }
}

# Create a public subnet 3 in AD3 in the new VCN
resource "oci_core_subnet" "webserver-subnet" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")}"
    cidr_block = "20.0.2.0/24"
    display_name = "webserver-subnet"
    dns_label = "websubnet"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.terraform-vcn.id
    route_table_id = oci_core_default_route_table.default-route-table.id ##
    dhcp_options_id = oci_core_virtual_network.terraform-vcn.default_dhcp_options_id

    security_list_ids = [oci_core_default_security_list.default-security-list.id] ##

    provisioner "local-exec" {
        command = "sleep 5"
    
    }
}

#----------------------------- Instances: 2x -------------------------------------------------
resource "oci_core_instance" "webserver1" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")}"
    compartment_id = var.compartment_ocid
    display_name = "webserver1"
    shape = var.instance_shape
    subnet_id = oci_core_subnet.webserver-subnet.id 
    hostname_label = "webserver1"

    metadata = {
        ssh_authorized_keys = var.ssh_public_key
    }

    source_details {
      source_type = "image"
      source_id = var.instance_image_ocid[var.region]
    }
  
}

resource "oci_core_instance" "webserver2" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")}"
    compartment_id = var.compartment_ocid
    display_name = "webserver2"
    shape = var.instance_shape
    subnet_id = oci_core_subnet.webserver-subnet.id 
    hostname_label = "webserver2"

    metadata = {
        ssh_authorized_keys = var.ssh_public_key
    }

    source_details {
      source_type = "image"
      source_id = var.instance_image_ocid[var.region]
    }
  
}

#-------------------------------- Load Balancer -----------------------------------------------
# Create a Load Balancer
resource "oci_load_balancer" "lb1" {
    shape = "100Mbps"
    compartment_id = var.compartment_ocid
    subnet_ids = [
        oci_core_subnet.lb-subnet1.id,
        oci_core_subnet.lb-subnet2.id
    ]

    display_name = "LB-Web-Servers"
  
}

# Create a Load Balancer - Backend Set
resource "oci_load_balancer_backend_set" "lb-backend-set-1" {
    name = "lb-backend-set-1"
    load_balancer_id = oci_load_balancer.lb1.id 
    policy = "ROUND_ROBIN"
    health_checker {
        port        = "80"
        protocol    = "HTTP"
        url_path    = "/"
      
    }
  
}

resource "oci_load_balancer_hostname" "test_hostname1" {
  #Required
  hostname         = "app.example.com"
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  name             = "hostname1"
}

resource "oci_load_balancer_hostname" "test_hostname2" {
  #Required
  hostname         = "app2.example.com"
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  name             = "hostname2"
}


# Create the Load Balancer - Listner
resource "oci_load_balancer_listener" "lb-listner1" {
    name = "lb-listner-http"
    load_balancer_id = oci_load_balancer.lb1.id
    default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set-1.name 
    #ip_address = oci_core_instance.webserver1.private_ip 
    hostname_names = [
        "${oci_load_balancer_hostname.test_hostname1.name}", 
        "${oci_load_balancer_hostname.test_hostname2.name}"
    ]
    port = 80
    protocol = "HTTP"
    connection_configuration {
      idle_timeout_in_seconds = "8"
    }
}

# Create a loadbalancer backend with webserver1
resource "oci_load_balancer_backend" "lb-backend-1" {
    load_balancer_id = oci_load_balancer.lb1.id
    backendset_name = oci_load_balancer_backend_set.lb-backend-set-1.name 
    ip_address = oci_core_instance.webserver1.private_ip
    port = 80
    backup = false
    drain = false 
    offline = false 
    weight = 1
}

# Create a loadbalancer backend with webserver2
resource "oci_load_balancer_backend" "lb-backend-2" {
    load_balancer_id = oci_load_balancer.lb1.id
    backendset_name = oci_load_balancer_backend_set.lb-backend-set-1.name 
    ip_address = oci_core_instance.webserver2.private_ip
    port = 80
    backup = false
    drain = false 
    offline = false 
    weight = 1
}

output "lb_public_ip" {
    value = ["${oci_load_balancer.lb1.ip_addresses}"]
}

