# Setup a Public Load Balancer in Oracle Cloud Infrastructure (OCI)

---
### Summary
- [x] Create a VCN in OCI using lab_2 script if you don't have any VCN setup or if you want a clean simulation environment with a seperate VCN.
- [x] Create an Instance Pool with 2x compute instances with instance configured with Nginx webserver with user_data in instance metadata.
- [x] Create a Public Load Balancer in the newly created VCN's public subnet with backend servers as created in instance pool.
  - [x] We will configure for HTTP and HTTPS listener
  - [x] HTTPS listener will require SSL certificates which are automatically generated using `setup_root_ca.yaml` file during execution of the `sample_loadbalancer_create.yml` playbook.
- [x] Delete the Public Load Balancer if you don't need it.

---

---
### Task-0: Setup the ROOT-CA certificate and remote-client certificate and CSR
- [x] Create a directory for certificates
- [x] Generate ROOT CA Private Key and Certificate
  - [x] `ca.key` : Generate ROOT CA Private key using OPENSSL, 2048 bits using RSA algo
  - [x] `ca.crt` : Generate ROOT CA Certificate valid for 1 year using its own private key in PKI. 
  This certificate will be used to sign the CSR's from the remote client/server for that after generating the ca.crt, 
  you have to distribute it to the remote_clients the ca.crt file contains the Public Key of ROOT CA, which then remote_client will use for sender authentication and sender non-repudiation.
- [x] Let Remote-client generates its Private Key and Certificate Signing Request (CSR)
  - [x] Generate Private Key `ansibleclient.key` for Remote Client; Here `ansibleclient` in Oracle Cloud Infrastructure will act as our remote client.
  - [x] Remote Client `ansibleclient` generates an CSR `ansibleclient.csr` .
  This CSR will be sent to ROOT-CA to sign and issue the Remote-Client a certificate.
  So that every who trusts ROOT-CA, thereby trusts Remote-Client.
- [x] ROOT-CA sign the CSR and issue a certificate to Remote-Client
---

### Prerequisite: Read the contents of the certificates and keys
### Task-01: Create a Public Load Balancer using module `oci_loadbalancer_load_balancer`
- [x] Inputs: {compartment_id, name/of the LB, shape_name:/100Mbps/Dont Randomly put a name, subnet_ids/ a List }
- [x] Outputs: {`public_load_balancer_id`, public_load_balancer_ip_addresses/ a List}

### Task-02: Create Backend Set | 3x sub-tasks
#### 2.1 Create a Backend set and name it and configure the health check policy using module `oci_loadbalancer_backend_set`
- [x] Inputs: {`load_balancer_id`, `name/of the backend set`, policy/round_robin}
- [x] Inputs: health_checker: {protocol/HTTP, port/80, interval_in_millis, timeout_in_millis, retries/3, return_code/200, url_path, response_body_regex}

#### 2.2 Add 2x Backend Servers (01 and 02) in Backend Set using module `oci_loadbalancer_backend`
- [x] Inputs for Backend Server-01: {`load_balancer_id`, `backend_set_name`, ip_address/backend server-01 private ip, port/80, backup/false, drain/false, offline/false, weight/1}
- [x] Inputs for Backend Server-02: {`load_balancer_id`, `backend_set_name`, ip_address/backend server-02 private ip, port/80, backup/false, drain/false, offline/false, weight/1}

### Task-03: Configure Listener
#### 3.1 Load Certificates and Private Key for Listener. Certificate/Key contents will be loaded as string using module `oci_loadbalancer_certificate`
- [x] Inputs: {`load_balancer_id`, certificate_name/of LB, ca_certificate/`ca.crt`, private_key/`ansibleclient.key`, public_certificate/`ansibleclient.crt` signed by ca.crt}

#### 3.2 Create Listener for HTTP Traffic using module `oci_loadbalancer_listener`
- [x] Inputs: {`load_balancer_id`, name/of the http_listener, `default_backend_set_name`, port/80, protocol/HTTP connection_configuration>>idle_timeout}

#### 3.3 Create Listener for HTTPS Traffic using module `oci_loadbalancer_listener`
- [x] Inputs: {`load_balancer_id`, name/of the http_listener, `default_backend_set_name`, port/443, protocol/HTTP/Should not be HTTPS here, ssl_configuration>> certificate_name/`lb_certificate_name`, ssl_configuration>> verify_peer_certificate/False}

### Task-04: Check whether Load Balancer able to access Backend Server using module `uri - an non-oci module`
- [x] Inputs: url/http://{{`public_load_balancer_ip_addresses[0]`.ip_address}}, body_format/json, timeout/600ms, retries/10 times, delay: 60s, until/result[status]==200

## Execution of the Script
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
