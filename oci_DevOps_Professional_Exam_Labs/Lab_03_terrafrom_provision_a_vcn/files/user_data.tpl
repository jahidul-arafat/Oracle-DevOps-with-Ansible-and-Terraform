#cloud-config init file

runcmd:
  - echo "cloud-config init file execution begins" >> ~/test.txt
  - sudo yum install -y yum-utils
  - sudo yum-config-manager --enable ol8_developer ol8_developer_EPEL
  - sudo yum clean all
  - sudo firewall-offline-cmd --zone=public --add-service=http
  - sudo systemctl restart firewalld
  - sudo yum install -y nginx
  - sudo systemctl enable nginx
  - sudo systemctl start nginx
  - echo "cloud-config init file execution ends" >> ~/test.txt
