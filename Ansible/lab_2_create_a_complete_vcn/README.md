
# Creating a Complete VCN in Oracle Cloud Infrastructure

---
**Variable Naming Conventions**
- [x] Input variable names should be as it is in the ansible-doc of that respective oracle.oci module.
- [x] Changing the input variable names would throw exceptions and results in error.
- [x] Output variable names can be user defined.
---
### This script will help you setup the following VCN components in your OCI:
#### Task-01: Creating a VCN using module: `oracle.oci.oci_network_vcn`
- [x] Inputs
  - [x] cidr_block of the VCN
  - [x] compartment_id, under which compartment OCID you VCN will be deployed
  - [x] display_name of the VCN in OCI Console
  - [x] dns_label, set the dns label for your VCN which will be used for FQDN (Fully Qualified Domain Name)
- [x] Output
  - [x] vcn_id of the generated VCN

#### Task-02: Create Gateways : IGW for Public Subnet and NGW for Private Subnet using `module: oci_network_internet_gateway`
- [x] Create an internet gateway which will be later attached to the default route table
  - [x] Inputs: {compartment_id, vcn_id, name/of the IGW, is_enabled}
  - [x] Output: IGW ID-> ig_id
- [x] Create a Nat Gateway so that instances in private subnet can egress to internet, but no ingress. Attach this NGW into a route rule for private subnet
  - [x] Inputs: {compartment_id, vcn_id, display_name/ of the NGW}
  - [x] Outputs: NGW ID: ng_id

#### Task-03: Create 2x Route Tables: Public Route Table and Private Route Table using module `ansible-doc oracle.oci.oci_network_route_table`
- [x] Create a Public route table to connect internet gateway to the VCN
  - [x] Inputs: {compartment_id, vcn_id, display_name/of the route table, route_rules/for the public route table where including 0.0.0.0/0 and ig_id associated}
  - [x] Output: Public Route Table ID -> public_rt_id
- [x] Create a Private route table to connect NGW to VCN
  - [x] Inputs: {compartment_id, vcn_id, display_name/of the route table, route_rules/for the private route table where including 0.0.0.0/0 and ng_id associated}
  - [x] Output: Private Route Table ID -> private_rt_id

#### Task-04: Create 2x Security List: Public Security List and Private Security List  which will be attached to respective subnets using module `oci_network_security_list`
- [x] Importing the Security List Preprocessing tasks as defined under templates/egress_security_rule.yaml.j2 and templates/ingress_security_rule.yaml.j2 as jinja framework
- [x] Create a Security list for allowing access to Public subnet.
  - [x] Inputs: {name/of the security list, compartment_id, vcn_id, ingress_security_rules, egress_security_rules / as imported from the jinja framework above}
  - [x] Output: public_security_list_ocid
- [x] Create a Security list for Private subnet.
  - [x] Inputs: {name/of the security list, compartment_id, vcn_id, ingress_security_rules, egress_security_rules}
  - [x] Output: public_security_list_ocid

#### Task-05: Create 2x Subnet: Public Subnet and Private Subnet using module `oci_network_subnet`
- [x] Creating a Public Subnet. Link security_list and route_table with it
  - [x] Inputs: {availability_domain, cidr_block, compartment_id, vcn_id, dns_label, display_name/of the subnet in OCI console, prohibit_public_ip_on_vnic/false, route_table_id, security_list_ids}
  - [x] Outputs: public_subnet_id
- [x] Creating a Private Subnet. Link security_list and route_table with it
  - [x] Inputs: {availability_domain, cidr_block, compartment_id, vcn_id, dns_label, display_name/of the subnet in OCI console, prohibit_public_ip_on_vnic/true, route_table_id, security_list_ids}
  - [x] Outputs: public_subnet_id


### Execute the Script
```shell
# Create a VCN in Oracle Cloud
> ansible-playbook sample_create_vcn.yml --syntax-check 
> ansible-playbook sample_create_vcn.yml --list-tags
> ansible-playbook sample_create_vcn.yml -vvv
```

### Update the VCN information in Oracle Cloud
```shell
# Update the VCN information in Oracle Cloud
> ansible-playbook sample_orchestrate_vcn.yml --syntax-check 
> ansible-playbook sample_orchestrate_vcn.yml --list-tags
> ansible-playbook sample_orchestrate_vcn.yml --tags "create_vcn" -vvv
```

### Teardown a VCN
```shell
# Completely Delete a VCN, release and delete the associated resources first
> ansible-playbook sample_teardown_vcn.yml --syntax-check 
> ansible-playbook sample_teardown_vcn.yml -v
```




