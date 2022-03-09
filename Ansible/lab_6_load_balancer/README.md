# Setup a Public Load Balancer
```shell
# Create a complete VCN (optional, if you dont have any VCN setup in your OCI)
> ansible-playbook ../lab_2_create_a_complete_vcn/sample_create_vcn.yml -vvv 

# Create an Instance Pool with Instance Configuration    
# this instance pool will load 2x webserver having nginx running               
> ansible-playbook ../lab_4_create_oci_instance_pool/sample_instance_pool_create.yml -vvv

# Main Part: Creating LB
# Create a Public Load Balancer with the instances launched by the Instance Pool
# Reset your compartment_ocid, public_subnet_id and instance's private ip
# Don't reset in code, instead pass the required value when prompt 
# This system will auto-generate the CA keys and certs as integrated into the solution
# You may find the keys and certs in ./ca_certificates after executing this ansible playbook
> ansible-playbook sample_loadbalancer_create.yml --list-tags
> ansible-playbook sample_loadbalancer_create.yml --list-tasks
> ansible-playbook sample_loadbalancer_create.yml --syntax-check 
> ansible-playbook sample_loadbalancer_create.yml -vvv

# Main Part: Deleting an existing Load Balancer
> ansible-playbook sample_loadbalancer_teardown.yml --list-tasks
> ansible-playbook sample_loadbalancer_teardown.yml -vvv
```
