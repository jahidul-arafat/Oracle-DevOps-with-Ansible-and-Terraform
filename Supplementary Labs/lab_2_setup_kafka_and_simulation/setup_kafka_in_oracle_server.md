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
```bash
> source kafka-aliases-by-ja.sh
```
### Kafka Topic
- [x] `k_topicList` : List all existing Kafka Topics
- [x] `k_topic_create`: Create the topic only if it doesnt exist
- [x] `k_topic_alter_partition`: Increase the Number of Kafka Topic Partitions
- [x] `k_topic_delete`: Delete a Kafka Topic
- [x] `k_topic_describe`: Describe a topic
- [x] `k_topic_get_all_msg` : List all messages in a Kafka Topic
- [x] `k_topic_purge`: Temporarily update the retention time on the topic to one second. 
Default retention time of Kafka topic is 168 hours, i.e. 7 days
- [x] `k_topic_purge_del_config`: Once purged, restore the previous retention.ms value.
- [x] `k_topic_del_all_mgs`: Delete all Messages from a Kafka Topic

### Kafka Producer
- [x] `k_producer`: Create a Kafka Console Producer publishing message/data to a specific topic

### Kafka Consumer and Consumer Group
- [x] `k_consumer`: Create a Kafka Console Consumer consuming message/data from a specific topic with system defined consumer group name
- [x] `k_cg_list` : List all consumer groups across all topics
- [x] `k_consumer_sysdef_cg` : Create a Kafka Console Consumer consuming message/data from a specific topic with system defined consumer group name
- [x] `k_consumer_userdef_cg`: Create a Kafka Console Consumer consuming message/data from a specific topic with user defined consumer group name
- [x] `k_cg_describe`: Get the details of a Specific Consumer Group. This will help you to get an insight of which topics are associated with this consumer group.
i.e. multiple topics could be using the same consumer group
- [x] `k_cg_active_members` : Get the list of all Active members in the Consumer Group

### Kafka Broker
- [x] `k_broker_describe` : Get the details of a Kafka broker
- [x] `k_broker_alter_log_cleaner_bg_threads` : Altering Kafka Broker- Adding a Configuration in a Kafka Broker
- [x] `k_broker_del_config` : Delete a broker configuration
- [x] `k_broker_restart` : Restart Kafka Broker
