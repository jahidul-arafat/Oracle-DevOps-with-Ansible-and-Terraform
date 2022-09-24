# Lab 06: Creating a File System
/*
    - create file system
    - create mount target
    - create export set:: associated with mount target
    - export the file system with path: associated with file_system and mount_target::export_set
*/

variable "tenancy_ocid" {
  
}

variable "compartment_ocid" {
  
}

variable "availability_domain" {
    default = 1
  
}

variable "subnet_ocid" {
    default = "ocid1.subnet.oc1.iad.aaaaaaaa2bm7w3yweeoqrjd4rooqfsrpcsfelhmjbx7rfho4bhqwpllvjroq"
  
}

# getthe list of all availability domains
data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.compartment_ocid}" # this will return a list of all ADs, which can be accessed by AD[0], AD[1] or AD[2]
}

# 1. Creating a file system
resource "oci_file_storage_file_system" "test_file_system" {
    #Required
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")}"
    compartment_id = var.compartment_ocid

    #Optional
    display_name = "terraform-filesystem"

  
}

# 2. Creating a Mount Target
resource "oci_file_storage_mount_target" "test_mount_target" {
    #Required
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")}"
    compartment_id = var.compartment_ocid
    subnet_id = var.subnet_ocid

    #Optional
    display_name = "terraform-mount"
}

# 3. Creating an export set associated with the mount target. 
# This export set will be used later when exporting the file system with a specific path
resource "oci_file_storage_export_set" "test_export_set" {
    #Required
    mount_target_id = oci_file_storage_mount_target.test_mount_target.id

    #Optional
    display_name = "terraform_export"
    max_fs_stat_bytes = 23843202333
    max_fs_stat_files = 223442
}

# 4. Final Step: Exporting the file system.
# This required: (a) file_system_id (b) mount target export set id
resource "oci_file_storage_export" "test_export" {
    #Required
    export_set_id = oci_file_storage_mount_target.test_mount_target.export_set_id
    file_system_id = oci_file_storage_file_system.test_file_system.id 
    path = "/terraform_filesystem"

    export_options {
        source = "0.0.0.0/0"
        access = "READ_WRITE"
        identity_squash = "NONE"
        require_privileged_source_port = false 
    }
}


