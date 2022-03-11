# OCI Ansible Collection Setup in virtual environment
## Setting the Environment
- [x] Setting up the OCI API in localhost as non-root user
- [x] Installing Ansible
- [x] Setting up an Ansible Python Virtual environment with Ansible, OCI SDK
- [x] Install the oracle.oci modules from the git for Ubuntu Linux. Process is much easier for Oracle Linux
- [x] For generating the OCI Facts and reporting after the execution of Oracle Ansible Script which will produce a JSON like report,
I am added a new module named `oci_json_patch` which is not available in the default OCI Collection modules.

```shell
# Setting up the OCI API in localhost / Dont try at root user
> mkdir ~/.oci
> cd .oci/
> openssl genrsa -out oci_api_key.pem 2048                              # Generate private key
> openssl rsa -pubout -in oci_api_key.pem -out oci_api_key_public.pem   # Generate public key
> openssl rsa -pubout -outform DER -in oci_api_key.pem | openssl md5 -c # Generate message digest/fingerprint
# Copy and paste the oci_api_key_public.pem Public Key in Settings> users> API Keys> Add API Key in OCI console and compare the fingerprint 
# Check the ~/.oci/config file
> cat ~/.oci/config
[DEFAULT]
user=<your_user_ocid>
fingerprint=<fingerprint from api key>
tenancy=<your tenancy ocid>
region=ap-mumbai-1
key_file=~/.oci/oci_api_key.pem

# Install Ansible in Ubuntu
> sudo apt update
> sudo apt install software-properties-common
> sudo add-apt-repository --yes --update ppa:ansible/ansible
> sudo apt install ansible

# Setting up a ansible python virtual environment with ANSIBLE, OCI SDK and ORACLE.OCI module installed
> python3 -m virtualenv ansible
> source ansible/bin/activate
(ansible)>  python3 -m pip install ansible      # install ansible python SDK
(ansible)>  ansible --version
(ansible)> pip3 install oci                     # install OCI SDK
# Install the oracle.oci modules from the git for Ubuntu Linux. Process is much easier for Oracle Linux
(ansible)> curl -L https://raw.githubusercontent.com/oracle/oci-ansible-collection/master/scripts/install.sh | bash -s -- --verbose
```


