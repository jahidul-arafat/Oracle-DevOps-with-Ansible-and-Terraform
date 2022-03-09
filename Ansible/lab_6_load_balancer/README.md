# Setup a Public Load Balancer in Oracle Cloud Infrastructure (OCI)
- [x] Create a VCN in OCI using lab_2 script if you don't have any VCN setup or if you want a clean simulation environment with a seperate VCN.
- [x] Create an Instance Pool with 2x compute instances with instance configured with Nginx webserver with user_data in instance metadata.
- [x] Create a Public Load Balancer in the newly created VCN's public subnet with backend servers as created in instance pool.
  - [x] We will configure for HTTP and HTTPS listener
  - [x] HTTPS listener will require SSL certificates which are automatically generated using `setup_root_ca.yaml` file during execution of the `sample_loadbalancer_create.yml` playbook.
- [x] Delete the Public Load Balancer if you don't need it.
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
