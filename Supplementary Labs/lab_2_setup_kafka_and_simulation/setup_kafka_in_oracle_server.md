# Kafka Setup in Oracle Linux 8 at Oracle Cloud Infrastructure and at local machine using Vagrant
## Machine Setup using Vagrant
```bash
# Create a Oracle Linux 8 VM in VirtualBox using Vagrant
> vagrant init generic/oracle8    # Oracle Linux Version 8.4
> vagrant status                  # Check your VM status
> vagrant ssh                     # SSH to the oracle VM
```

## Alternatively if you want to setup in Oracle Cloud Environment
- [x] Go to Compute Instance > Launch a VM with Oracle Linux 8.5
- [x] Then SSH to that Machine

## Setting up Kafka in VM/Sever
```bash
# Into the VM
# User: vagrant
# Setup repos
> sudo dnf update

# Check the existing repository list
> sudo yum repolist all # Check if you could find oracle-developer-EPEL repo. If no, then you have to install the EPEL repo
> sudo dnf install epel-release
> sudo yum repolist all # Now EPEL repo will be available and active

# Install JAVA JDK
> sudo dnf install java-11-openjdk
> sudo dnf install java-latest-openjdk
> java --version # Check the java version

# Install some necessary tools:: Optional
> sudo dnf install vim wget

# Download the Kafka Binary
# Dont download the source version as this requires a build
# https://kafka.apache.org/downloads
> wget https://dlcdn.apache.org/kafka/3.1.0/kafka_2.12-3.1.0.tgz
> tar -xf kafka_2.12-3.1.0.tgz
> sudo mv kafka_2.12-3.1.0/ /usr/local/kafka  # this is because so that you dont accidentally delete kafka

# Create the Zookeeper and Kafka Service Daemons
> sudo vim /etc/systemd/system/zookeeper.service
---
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/bin/bash /usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
ExecStop=/usr/bin/bash /usr/local/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target

---

> sudo vim /etc/systemd/system/kafka.service
---
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/jre-11-openjdk"
ExecStart=/usr/bin/bash /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/bin/bash /usr/local/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
---

> sudo systemctl daemon-reload
> sudo systemctl enable zookeeper
> sudo systemctl enable kafka
> sudo systemctl start zookeeper
> sudo systemctl start kafka
> sudo systemctl status zookeeper
> sudo systemctl status kafka
```

# Execute your Kafka Alias Script
Following Services are available in this kafka alias script:
- [x] `k_list_topics`  : To list all the exisiting kafka topics
- [x] `k_create_topic` : To Create a kafka topic
- [x] `k_delete_topic` : To Delete a kafka topic
```bash
> chmod +x kafka-aliases-by-ja.sh
> ./kafka-aliases-by-ja.sh
```


---
## References
### ZooKeeper
#### Q1. Why removing ZooKeeper from kafka?
#### Q2. Can Kafka run without ZooKeeper?
- [x] For any distributed system, there needs to be a way to coordinate tasks.  Kafka is a distributed system that was built to use ZooKeeper.  
However, other technologies like **Elasticsearch** and **MongoDB** have their own built-in mechanisms for coordinating tasks.
- [x] ZooKeeper is used in distributed systems for service synchronization and as a naming registry.  
- [x] When working with Apache Kafka, ZooKeeper is primarily used to track the status of nodes in the Kafka cluster and maintain a list of Kafka topics and messages
- [x] Starting with v2.8, Kafka can be run without ZooKeeper. However, this update isn’t ready for use in production
  - **Why Removing ZooKeeper from Kafka?**
  - Because Using ZooKeeper with Kafka adds complexity for tuning, security, and monitoring
  - Instead of optimizing and maintaining one tool, users need to optimize and maintain two tools
  - **How does Kafka Run without ZooKeeper?**
    - The latest version of Kafka uses a new **quorum controller**.  
    - This quorum controller enables all of the metadata responsibilities that have traditionally been managed by both the Kafka controller and ZooKeeper 
    - This is to be run internally in the Kafka cluster.
- [x] ZooKeeper isn’t memory intensive when it’s working solely with Kafka.  About 8 GB of RAM will be sufficient for most use cases.
- [x] Just as it’s important to monitor Kafka performance in real-time to diagnose system issues and prevent future problems, it’s critical to monitor ZooKeeper.
Use Elasticsearch to monitor Kafka and ZooKeeper. 
- [x] Read more at: https://dattell.com/data-architecture-blog/what-is-zookeeper-how-does-it-support-kafka/

### ZooKeeper has five primary functions
- [x] Controller Election
- [x] Cluster Membership
- [x] Topic Configuration
- [x] Access Control Lists (ACLs)
- [x] Quotas 


---
