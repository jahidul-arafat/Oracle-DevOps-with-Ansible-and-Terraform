# Create a VCN and Launch Compute Instance usng IaC: Terraform
- All OCI Terraform Resource List: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/guides/resource_discovery
- use the variables defined in terraform.tfvars or bash profile file
- Ref: https://github.com/terraform-providers/terraform-provider-oci/issues/570

### Setup Guidelines
- [x] Create a VCN
- [x] Create 2x Gateways: Internet Gateway and NAT Gateway
- [x] Create 2x Route Tables: Public Route Table (IGW), Private Route Table (NGW)
- [x] Create a Public Security List 
- [x] Create 2x Subnets: Public Subnets (rt_public, sl_public), Private Subnet (rt_private)
- [x] Launch a public instance with SSH enabled and install a nginx server into it with user data

### Important Configuration Files
- [x] terraform.tfvars - I kept it private due to some secret credentials
- [x] [variables.tf](./variables.tf) : Where I have defined all the required variables
- [x] [datasources.tf](./datasources.tf) : I used this to load several datas i.e. setting providers and loading data related to ADs
- [x] [vcn.tf](./vcn.tf) : This script will create a complete VCN for you
- [x] [compute.tf](./compute.tf) : This script will create a public and private compute instances in respective subnets
- [x] [output.tf](./output.tf) : This is to output the information related to resoruces created with the above terraform scripts

### Execution Commands
```shell
> terraform init
> terraform validate  # validate the terraform syntax in the scripts
> terraform plan --var-file ../../../MyDevSecrets/terraform.tfvars -out <location_to_store_the_plan>
> terraform apply --var-file ../../../MyDevSecrets/terraform.tfvars
> terraform destroy --var-file ../../../MyDevSecrets/terraform.tfvars

```
