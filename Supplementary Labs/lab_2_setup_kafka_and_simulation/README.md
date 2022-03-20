# Hello Kafka: Getting Acquainted With Data Streaming and Setup Kafka in Oracle Cloud Environment and On-prem Oracle Linux VM
By Jahidul Arafat

---
## A. Kafka : A Short Note
Ref: https://www.oak-tree.tech/blog/big-data-kafka

Kafka is a big data streaming platform. It is used by many enterprises to:
- [x] Provide `streams` of records, similar to a message queue or enterprise messaging system, 
to which clients may publish data or subscribe.
- [x] Store streams of records in a `fault-tolerant`, `durable way` so that clients may consume the streams 
and take action on the data.
- [x] Kafka is a message system which can be used to build `data streams`. 
It is used to manage the flow of data and ensure that data is delivered to where it is intended to go.

_Since its introduction at LinkedIn in 2011, Kafka has become an essential part of the Big Data landscape. 
Through the use of its "topics" and ecosystem of components, Kafka provides a uniform way to move data between systems, 
while providing the foundation for stream analytics and building applications that are able to react to data as it becomes available._

Kafka provides two main uses cases which make it an "application hub":
- [x] Stream Processing: enables continuous, real-time applications to react to, process and transform streams.
- [x] Data Integration: the streaming platform captures streams of events and feeds those to other data systems including Hadoop, NoSQL (key/value systems or document stores), 
Object Storage (like MinIO, Ceph, Amazon S3, and OpenStack Swift), and relational databases.

### A.1 How Kafka is effective and different from RabbitMQ?
- [x] Real-time publication/subscription at large scale. Kafka's implementation allows for low latency, making it possible for real-time applications to leverage Kafka on time sensitive data and still operate with high throughput capacity.
- [x] Capabilities for processing and storing data. 

**Kafka is slightly different from other messaging applications, like `RabbitMQ`, 
in that `stores data for a period of time`. 
The storage of data `persistently` allows for `re-playing` of the data, 
as well as `integration` with batch-systems like `Hadoop` or `Spark`.**

## B. ZooKeeper: A short Node
### Q1. Why removing ZooKeeper from kafka?
### Q2. Can Kafka run without ZooKeeper?
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


## 1. Setup Kafka
Check the setup guidelines [here](setup_kafka_in_oracle_server.md)

## 2. Let's Play with Kafka and JA
Here I have developed a Kafka alias script to make your kafka command line operations easy.
### 2.1 Kafka Topic
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

### 2.2 Kafka Producer
- [x] `k_producer`: Create a Kafka Console Producer publishing message/data to a specific topic

### 2.3 Kafka Consumer and Consumer Group
- [x] `k_consumer`: Create a Kafka Console Consumer consuming message/data from a specific topic with system defined consumer group name
- [x] `k_cg_list` : List all consumer groups across all topics
- [x] `k_consumer_sysdef_cg` : Create a Kafka Console Consumer consuming message/data from a specific topic with system defined consumer group name
- [x] `k_consumer_userdef_cg`: Create a Kafka Console Consumer consuming message/data from a specific topic with user defined consumer group name
- [x] `k_cg_describe`: Get the details of a Specific Consumer Group. This will help you to get an insight of which topics are associated with this consumer group.
i.e. multiple topics could be using the same consumer group
- [x] `k_cg_active_members` : Get the list of all Active members in the Consumer Group

### 2.4 Kafka Broker
- [x] `k_broker_describe` : Get the details of a Kafka broker
- [x] `k_broker_alter_log_cleaner_bg_threads` : Altering Kafka Broker- Adding a Configuration in a Kafka Broker
- [x] `k_broker_del_config` : Delete a broker configuration
- [x] `k_broker_restart` : Restart Kafka Broker
