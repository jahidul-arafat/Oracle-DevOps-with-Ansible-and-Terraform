# How to Setup and Configure a Certificate Authority (CA) on Oracle Linux 8.5 (Hands-on/Manual)
#### You can find the ansible automation scripts for ROOT CA and Remote-Clinet PKI setup [HERE](./setup_root_ca.yaml) .

---
### Notes
- [x] CA is an entity responsible for issuing digital certificates to verify identity of websites and other services on the internet.
- [x] Building a private CA will enable you to configure, test and run programs that require encrypted connections between a client and a server.
- [x] With private CA, you can issue certificates for users, servers or individual programs and services within your infrastructure.
- [x] OpenVPN and Puppet use their own private CA.
- [x] We can also configure our webserver to use certificates issued by a private CA in order to make development and staging environments match production servers that use TLS to encrypt connections.
---

### Objectives
- [x] To setup a private CA on an Oracle Linux Server
- [x] To generate and sign a testing certificate using the new CA.
- [x] Import CA server's public certificate into remote client's operating system's certificate store, so that
you can verify the chain of trust between the CA and remote server's or users.
- [x] Revoke a certificate to prevent a user or server from using it and distribute a Certificate Revocation List (CRL)
to make sure only authorized users and systems can use services that rely on your CA.

## My Architecture
- In my case, **ansibleserver** will act as my **CA server**
- 2x ansible clients (i.e **ansibleclient** and **ansibleclient1**) will act as the remote client who will generate the Certificate signing request to CA-Server

---
### Pseudo Simulation
**@ca-server/ansibleserver [PKI setup and Create CA]**
- **[1.]** We will setup PKI infrastructure here using `easy-rsa`
- **[1a.]** Then will create a CA Authority using `build-ca` command. 
  - **[1a.i.]** This will generate a `ca.crt` (public key certificate) and a `ca.key` (private key of CA server)
- **[1b.]** Then, distribute the CA's public key certificate `ca.crt` to remote clients (i.e. ansibleclient and ansibleclient1)
  - Distribution tool: `scp`
  - Make sure in remote-clients /etc/ssh/sshd_config, Password Authentication is enabled.

**@remote-client/ ansibleclient, ansibleclient1 [create private key and csr]**
- **[2.]** Once `ca.crt` is distributed to remote clients (i.e. ansibleclient and ansibleclient1), then
  - **[2a.]** Put that `ca.crt` to remote client's Operating System's Certificate store and update the CA certificates/trust
- **[3.]** @remote-clients
  - **@ansibleclient**:  
    - create private key (ansibleclient.key) and a certificate signing request (ansibleclient.req)
    - Copy the CSR file (ansibleclient.req) to CA Server/ansibleserver using SCP
  - **@ansibleclient1**: 
    - create private key (ansibleclient1.key) and a certificate signing request (ansibleclient1.req)
    - Copy the CSR file (ansibleclient1.req) to CA Server/ansibleserver using `SCP`
    
**@CA server/ansibleserver - Sign the CSR's from remote-client by CA's Private key and send back to them**
- **[4.]** Import the remote-client's CSR request using `easy-rsa`
  - **[4a.]** Sign the `request` using the CA server's Private Key `ca.key` # check if your CA server's `ca.key` is encrypted or not
    - Output: ansibleclient.crt, ansibleclient1.crt
    - Contains remote-server's public key + a new signature from CA server
  - **[4b.]** Send the signed `csr - ansibleclient.req/ansibleclient1.req` to remote server (i.e. ansibleclient, ansibleclient1) that made the CSR request sing `scp` / or we can call it 'issue the certificates to those who has made the request'

@CA Server/ansibleserver - Try to revoke the certificate of a remote client who might have left or posses threat
- [5.] Revoke the remote client, this will generate a revocation certificate
  - [5a.] Generate a certificate revocation list (CSL) and transfer that to the revoked remote client, so that he can no longer use that certificate.
---

### Step-1: Install Easy-RSA on CA server

```shell
# @ansibleserver; user: <opc>
# Step-1: Install Easy-RSA and setting up the Public Key Infrastructure at CA server/ansibleserver
> sudo yum update
> wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz   #Download the easy-rsa repo from git
> tar xvf EasyRSA-3.0.8.tgz 
> mv EasyRSA-3.0.8 easy-rsa
> chmod 700 easy-rsa  # To restrict access to your new PKI directory, ensure that only the owner can access it

> cd ~/easy-rsa       # look for easyrsa executable file
> ./easyrsa init-pki  # initialize the PKI inside the easy-rsa directory
---
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /home/opc/easy-rsa/pki

# Now, at this stage our Public Key Infrastructure (PKI) is ready
# Next: Is to create a Certificate Authority
---

# Step-2: Creating a Certificate Authority in CA-Server/ansibleserver
> cd ~/easy-rsa
> vim vars
---
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "NewYork"
set_var EASYRSA_REQ_CITY       "New York City"
set_var EASYRSA_REQ_ORG        "ansibleserver"
set_var EASYRSA_REQ_EMAIL      "ansibleserver@example.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
---

> ./easyrsa build-ca    # build the CA; this will generate 1x ca.crt (Public key certificate) and 1x ca.key (private key) 
> cat pki/ca.crt
> cat pki/private/ca.key

# Step-3: Distribute CA-server's/ansibleserver's Public Key Certificate (ca.crt) to remote-clients (i.e. ansibleclient, ansibleclient1)
# @ca-server/ansible-server
> scp ca.crt opc@ansibleclient:/tmp
> scp ca.crt opc@ansibleclient1:/tmp

# @remote-clients - ansibleclient,ansibleclient1
> ll /tmp/ca.crt   # @ansibleclient, @ansibleclient1
> sudo cp /tmp/ca.crt /etc/pki/ca-trust/source/anchors/     # import the certificate into its operating system certificate store.
> sudo update-ca-trust

# Now your remote-client's (ansibleclient, ansibleclient1) will trust any certificate that has been signed by the CA server/ansibleserver.

# Step-4: Remote-server's Creating Certificate Signing request and send it to CA-server
# 4.1 Create private key and csr at each remote-server
#@opc:ansibleclient
> mkdir practice-csr
> cd practice-csr/
> openssl genrsa -out ansibleclient.key   # private key of asibleclient
> openssl req -new -key ansibleclient.key -out ansibleclient.csr    # create a Certificate signign request using the private key
> ll
> openssl req -in ansibleclient.csr -noout -subject  # Verify the contents of CSR
---
subject=C = BD, ST = Mirpur, L = Dhaka, O = ansibleclient, OU = SolE, CN = ansibleclient, emailAddress = ansibleclient@example.com
---
> 

#@opc:ansibleclient1
> mkdir practice-csr
> cd practice-csr/
> openssl genrsa -out ansibleclient1.key   # private key of asibleclient
> openssl req -new -key ansibleclient1.key -out ansibleclient1.csr  # create a Certificate signign request using the private key
> ll
> openssl req -in ansibleclient1.csr -noout -subject  # Verify the contents of CSR
---
subject=C = BD, ST = Mirpur, L = Dhaka, O = ansibleclient1, OU = SolE, CN = ansibleclient1, emailAddress = ansibleclient1@example.com
---

# 4.2 Copy the CSR file to CA-Server/ansibleserver
> scp ansibleclient.csr opc@ansibleserver:/tmp/      #@ansibleclient 
> scp ansibleclient1.csr opc@ansibleserver:/tmp/     #@ansibleclient1

# Next: CA-Server will import the CSR files from remote-clients

# Step-5: CA-Server imports the CSR files from remote-clients, 
# sign those with his Private Key (ca.key) 
# and send the signed CSR's back to remote-clients generated the CSR

# 5.1 CA-Server imports the CSR files from remote-clients
# @ca-server/ansibleserver
> ./easyrsa import-req /tmp/ansibleclient.csr ansibleclient         # importing ansibleclient's csr with a short name
---
Note: using Easy-RSA configuration from: /home/opc/easy-rsa/vars #<<<---
Using SSL: openssl OpenSSL 1.1.1k  FIPS 25 Mar 2021

The request has been successfully imported with a short name of: ansibleclient #<<<---
You may now use this name to perform signing operations on this request.
---

> ./easyrsa import-req /tmp/ansibleclient.csr ansibleclient         # importing ansibleclient's csr with a short name

# 5.2 CA-Server sign the CSR's using CA Server’s private key in ~/easy-rsa/pki/private/ca.key
# @ca-server/ansibleserver
# 3x types of sign-request: server, client, ca. We will use server
> ./easyrsa sign-req server ansibleclient                           # Signing ansibleclient's CSR using shortname <ansibleclient>

---
Note: using Easy-RSA configuration from: /home/opc/easy-rsa/vars
Using SSL: openssl OpenSSL 1.1.1k  FIPS 25 Mar 2021


You are about to sign the following certificate.
...

Certificate created at: /home/opc/easy-rsa/pki/issued/ansibleclient.crt
---

> ./easyrsa sign-req server ansibleclient1                           # Signing ansibleclient's CSR using shortname <ansibleclient>

> ll pki/issued 
> cat pki/issued/ansibleclient.crt                                   # Digital Certificate for ansibleclient
> cat pki/issued/ansibleclient1.crt                                  # Digital Certificate for ansibleclient1
                                                                     # Contains both remote-client Public Key + new Signature from CA-server
# ** The point of the signature is to tell anyone who trusts the CA that they can also trust the remote-server's certificate.                                                                     

# 5.3 Distribute the remote-server's newly generated crt (ansibleclient.crt, ansibleclient1.crt) to remote-servers those made the CSR request
#@ansibleserver
> scp pki/issued/ansibleclient.crt opc@ansibleclient:/tmp
> scp pki/issued/ansibleclient.crt opc@ansibleclient1:/tmp


# Step-6: Revoking a Certificate
# Only revoking a certificate will not revoke a remote client using that certificate.
# After the revoke, we have to generate a certificate revocation list and distribute this to remote-clients

# 6.1 Revoke the Certificate issued to `ansibleclient1`
# @ca-server/ansibleserver
> ./easyrsa revoke ansibleclient1
---
subject=
    countryName               = BD
    stateOrProvinceName       = Mirpur
    localityName              = Dhaka
    organizationName          = ansibleclient1
    organizationalUnitName    = SolE
    commonName                = ansibleclient1
    emailAddress              = ansibleclient1@example.com

X509v3 Subject Alternative Name:
    DNS:ansibleclient1


Type the word 'yes' to continue, or any other input to abort.
  Continue with revocation: yes
Using configuration from /home/opc/easy-rsa/pki/easy-rsa-3764787.I0KvUd/tmp.C5jZZE
Enter pass phrase for /home/opc/easy-rsa/pki/private/ca.key:
Revoking Certificate B756BDC07A6FFEB0F3994B2705F79C97.  # <<<----- Its a unique serial number
...
Revocation was successful. You must run gen-crl and upload a CRL to your
infrastructure in order to prevent the revoked cert from being accepted.
---

# 6.2 Generate a Certificate Revocation List (CRL)
# @ca-server/ansibleserver
> ./easyrsa gen-crl
---
...
An updated CRL has been created.
CRL file: /home/opc/easy-rsa/pki/crl.pem
---

> cat pki/crl.pem 
-----BEGIN X509 CRL-----
MIIBQDCBxgIBATAKBggqhkjOPQQDBDAYMRYwFAYDVQQDDA1hbnNpYmxlc2VydmVy
Fw0yMjAzMDcwOTUwNThaFw0yMjA5MDMwOTUwNThaMCQwIgIRALdWvcB6b/6w85lL
JwX3nJcXDTIyMDMwNzA5NDYyNlqgVzBVMFMGA1UdIwRMMEqAFPTAGbVmVA1vJa09
FoTqo2KtY641oRykGjAYMRYwFAYDVQQDDA1hbnNpYmxlc2VydmVyghRhRRVwCTyz
3onSP8PoM0bnQ8uAVDAKBggqhkjOPQQDBANpADBmAjEAmL2STMQaPsLD4nzYtUtb
s4LW87s5XFsYIcEf65o+kIu6KdbIF/tjHSp2YC7gadFZAjEA21BL/Ay/3BorG5Vk
779AbW8j98kXXIpgq7YrQQuqXq1swa8wQ5XXNog+0b0GZ9Wb
-----END X509 CRL-----

# 6.3 Transfer the CRL to remote-client whose certificate is revoked, else that remote-client will still be using that certificate even after being revoked at step-6.1
# @ca-server/ansibleserver
>  scp pki/crl.pem opc@ansibleclient1:/tmp

# Now that the file is on the remote system, 
# the last step is to update any services with the new copy of the revocation list.

# 6.4 Updating Services that Support a CRL
# @ca-server/ansibleserver
# If you would like to examine a CRL file, for example to confirm a list of revoked certificates
> openssl crl -in pki/crl.pem --noout -text
---
Revoked Certificates:
    Serial Number: B756BDC07A6FFEB0F3994B2705F79C97 <<<--- Same as of Step-6.1 for ansibleclient1/remote-client whose certificate has been revoked
        Revocation Date: Mar  7 09:46:26 2022 GMT
    
---
> openssl crl -in pki/crl.pem --noout -text | grep -A 1 B756BDC07A6FFEB0F3994B2705F79C97

```
### Conclusion
**In this tutorial, What we have learned ?** 
- [x] We have created a private Certificate Authority using the Easy-RSA package on a standalone Oracle Linux 8.5 Server. 
- [x] We learned how the trust model works between parties that rely on the CA. 
- [x] We also created and signed a Certificate Signing Request (CSR) for 2x remote-clients (ansibleclient, ansibleclient1) in Oracle Cloud Infrastructure and then learned how to revoke a certificate. 
- [x] Finally, we learned how to generate and distribute a Certificate Revocation List (CRL) for any system that relies on your CA to ensure that users or servers that should not access services are prevented from doing so.

Now you can issue certificates for users and use them with services like OpenVPN. 
You can also use your CA to configure development and staging web servers with certificates to secure your non-production environments. Using a CA with TLS certificates during development can help ensure that your code and environments match your production environment as closely as possible.

