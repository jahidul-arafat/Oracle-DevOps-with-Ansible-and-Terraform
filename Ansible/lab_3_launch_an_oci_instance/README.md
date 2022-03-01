# Overview

This sample shows how a public compute instance can be [launched](https://docs.us-phoenix-1.oraclecloud.com/Content/Compute/Tasks/launchinginstance.htm) and [accessed](https://docs.us-phoenix-1.oraclecloud.com/Content/Compute/Tasks/accessinginstance.htm) from the internet using SSH, through OCI ansible cloud modules.

```shell
> oci compute image list -c ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq
> export SAMPLE_PUBLIC_SSH_KEY=\`cat ~/.ssh/id_rsa.pub\` # use your localhost public key; 
# If this is not set, the sample will generate a new key-pair every run anyway.
> export SAMPLE_AD_NAME=oAOj:AP-MUMBAI-1-AD-1 # Cant' be AD-1 or AD-2 
> export SAMPLE_COMPARTMENT_OCID=ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq
> export SAMPLE_IMAGE_OCID=ocid1.image.oc1.ap-mumbai-1.aaaaaaaat5oyttcyce2bm2yaavxeongt5e5jcfkad5f7nvtal5hsvmer3ana
```

## Examine the Architecture




