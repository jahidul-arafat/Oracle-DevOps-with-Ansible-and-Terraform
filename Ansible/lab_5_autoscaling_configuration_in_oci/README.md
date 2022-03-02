```shell
# Prerequisite
# Create a complete VCN
> ansible-playbook ../lab_2_create_a_complete_vcn/sample_create_vcn.yml -vvv 
# Create an Instance Pool with Instance Configuration                   
> ansible-playbook ../lab_4_create_oci_instance_pool/sample_instance_pool_create.yml -vvv

# Create an autoscaling configuration | requires an instance pool
> ansible-playbook sample_autoscaling_create.yml --list-tags
> ansible-playbook sample_autoscaling_create.yml --list-hosts
> ansible-playbook sample_autoscaling_create.yml --list-tasks --tags autoscaleconfig_threshold
> ansible-playbook sample_autoscaling_create.yml --list-tasks --tags autoscaleconfig_scheduled
> ansible-playbook sample_autoscaling_create.yml --syntax-check
> ansible-playbook sample_autoscaling_create.yml -vvv

# Delete an existing autoscaling configuration
> ansible-playbook sample_autoscaling_teardown.yml -syntax-check 
> ansible-playbook sample_autoscaling_teardown.yml -vvv
```
