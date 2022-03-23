```shell
# Lets ping to all the hosts
> ansible all -m ping -i hosts.yml -u opc
> ansible-playbook playbook.yml --syntax-check -i hosts.yml

# By default firewalld in enabled in OCI instances
# for our testing purposes, ssh to the instances and stop firewalld
> sudo systemctl stop firewalld

```
