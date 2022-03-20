#!/bin/bash
# This Kafka Aliases is developed by Jahidul Arafat
# Architect at Oracle Corporation
# Technology Solution and Cloud Architecture
# JAPAC Solution Engineering


export KAFKA_HOME=/usr/local/kafka
export DEFAULT_BOOTSTRAP="localhost:9092"
export DEFAULT_BROKER="localhost:9092" # however you could have multiple brokers too. In this case, list all those broker with comma(,) seperated i.e. "localhost:9092,localhost:9093,localhost:9094"

#=====================================================================================================================
# Step-1: KAFKA TOPICS
# 1.1 List all existing Kafka Topics
k_topic_list(){
  echo "***A Topic is similar to a <QUEUE>"
  echo "If you have multiple brokers i.e. localhost:9092,localhost:9093,localhost:9094 then comma seperate them all when asked for BROKER"
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  $KAFKA_HOME/bin/kafka-topics.sh \
    --bootstrap-server $BROKER \
    --list
}

# 1.2 Create a Kafka Topic
# Create the topic only if it doesnt exist
# Default retention time of Kafka topic is 168 hours, i.e. 7 days
k_topic_create(){
  echo "***A Topic is similar to a <QUEUE>"
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Replicaton Factor [1-100]:" REP_FACTOR
  REP_FACTOR=${REP_FACTOR:-1}

  read -p "Partitions [1-100]:" PARTITION
  PARTITION=${PARTITION:-1}

  $KAFKA_HOME/bin/kafka-topics.sh \
    --create \
    --bootstrap-server $DEFAULT_BOOTSTRAP \
    --replication-factor $REP_FACTOR \
    --partitions $PARTITION \
    --topic $TOPIC_NAME \
    --if-not-exists
}

# 1.3 Increase the Number of Kafka Topic Partitions
# i.e. for any reason you need to increase the number of partitions for a specific topic, you can use the <--alter> flag
k_topic_alter_partition(){
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  read -p "Set the New Partition Size for Topic[$TOPIC_NAME][1-100]: " PARTITION_SIZE
  PARTITION_SIZE=${PARTITION_SIZE:-40}


  $KAFKA_HOME/bin/kafka-topics.sh \
    --bootstrap-server $BROKER \
    --alter \
    --topic $TOPIC_NAME \
    --partitions $PARTITION_SIZE
}

# 1.4 Delete a Kafka Topic
k_topic_delete(){
  echo "***A Topic is similar to a <QUEUE>"
  read -p "Enter Kafka Topic Name [If you want to delete multiple topic of a name i.e. test-topic-1, test-topic-2 use test-* or test*]: " TOPIC_NAME
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}

  $KAFKA_HOME/bin/kafka-topics.sh \
    --bootstrap-server $BROKER \
    --delete \
    --topic $TOPIC_NAME
}

# 1.5 Describe a topic
k_topic_describe(){
  echo "***A Topic is similar to a <QUEUE>"
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  $KAFKA_HOME/bin/kafka-topics.sh \
    --bootstrap-server $BROKER \
    --topic $TOPIC_NAME \
    --describe
}

# 1.6 List all messages in a Kafka Topic
k_topic_get_all_msg(){
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Max Number of Message you want to list from the Topic [$TOPIC_NAME]: " MAX_MSG_COUNT
  MAX_MSG_COUNT=${MAX_MSG_COUNT:-100}   # 100 messages


  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  $KAFKA_HOME/bin/kafka-console-consumer.sh \
    --bootstrap-server $BROKER \
    --topic $TOPIC_NAME \
    --from-beginning \
    --max-messages $MAX_MSG_COUNT
}

# 1.7 Special Case Scenario/ PURGING
# Purge a Kafka Topic and Delete all its messages

# Default retention time of Kafka topic is 168 hours, i.e. 7 days
# Simply change the retention period to one second temporarily and then change it back again
# 1000ms=1s

# Scenario:
# I pushed a message that was too big into a kafka message topic on my local machine, now I'm getting an error:
# kafka.common.InvalidMessageSizeException: invalid message size
# Increasing the fetch.size is not ideal here, because I don't actually want to accept messages that big.

# 1.7.1 Temporarily update the retention time on the topic to one second
# Configuration name: <retention.ms>
#altering
k_topic_purge(){
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  read -p "Set the Topic[$TOPIC_NAME] Retention Period in milliseconds: " RETENTION_PERIOD
  RETENTION_PERIOD=${RETENTION_PERIOD:-1000}  # 100ms=1s

  $KAFKA_HOME/bin/kafka-configs.sh \
    --bootstrap-server $BROKER \
    --alter \
    --entity-type topics \
    --entity-name $TOPIC_NAME \
    --add-config retention.ms=$RETENTION_PERIOD
}

# 1.7.2 Intermediate
# then wait for the purge to take effect (duration depends on size of the topic).
# Once purged, restore the previous retention.ms value

# 1.7.3 Once purged, restore the previous retention.ms value.
# To revert it back, simply delete the step-01 configuration <retention.ms>
k_topic_purge_del_config(){
  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  $KAFKA_HOME/bin/kafka-configs.sh \
    --bootstrap-server $BROKER \
    --alter \
    --entity-type topics \
    --entity-name $TOPIC_NAME \
    --delete-config retention.ms
}

# 1.8 Delete all Messages from a Kafka Topic
# This is similar to Purging Topic in Kafka
# Thats why I have made an alias of it
# Default retention time of Kafka topic is 168 hours, i.e. 7 days

alias k_topic_del_all_mgs="k_topic_purge"

#=======================================================================================================================
# Step-2: KAFKA Producer
# 2.1 Create a Kafka Console Producer publishing message/data to a specific topic
k_producer(){
  echo "Open both Producer and Consumer in different window to view the simulation"
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER} # Setting the default BROKER value

  read -p "Enter an existing Topic Name where Kafka will publish its stream data: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  $KAFKA_HOME/bin/kafka-console-producer.sh \
    --broker-list $BROKER \
    --topic $TOPIC_NAME
}

#======================================================================================================================
# Step-3: Kafka Consumer
# CG -> Consumer Group
# 3.1: List all consumer groups across all topics
# Every Kafka topic may have numerous consumer groups. In order to list all the consumer groups across all topics in a Kafka cluster,
# you can simply use the --list flag with the kafka-consumer-groups runner.
k_cg_list(){
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  $KAFKA_HOME/bin/kafka-consumer-groups.sh \
    --bootstrap-server $BROKER \
    --list
}

# 3.2 Create a Kafka Console Consumer consuming message/data from a specific topic with system defined consumer group name
# every kafka-console-consumer.sh execution will create a default random consumer group i.e. <console-consumer-44618, console-consumer-28619>
# instead of creating random consumer group, you can create your specific consumer group i.e. <testtopic-consumer-group>
k_consumer_sysdef_cg(){
  echo "Open both Producer and Consumer in different window to view the simulation"
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER} # Setting the default BROKER value

  read -p "Enter an existing Topic Name where Kafka is publishing is stream data: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Do you want consumer to fetch data from beginning: [0-No, 1-Yes] " FETCH_FROM_BEGINNING
  FETCH_FROM_BEGINNING=${FETCH_FROM_BEGINNING:-1}

  if  [[ $FETCH_FROM_BEGINNING -gt 0 ]] # means 'YES'
  then
    echo "Consumer Group Fetching data from beginning"
    $KAFKA_HOME/bin/kafka-console-consumer.sh \
      --bootstrap-server $BROKER \
      --topic $TOPIC_NAME \
      --from-beginning
  else
    echo "By default, new consumer grouip will not fetch older messages that got pushed to the Kafka topic/queue before defining consumer group"
    $KAFKA_HOME/bin/kafka-console-consumer.sh \
      --bootstrap-server $BROKER \
      --topic $TOPIC_NAME

  fi
}

# 3.3 Alias
alias k_consumer="k_consumer_sysdef_cg"

# 3.3 Create a Kafka Console Consumer consuming message/data from a specific topic with user defined consumer group name
k_consumer_userdef_cg(){
  read -p "Enter BROKER Name: [localhost:9092]" BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  read -p "Enter Kafka Topic Name: " TOPIC_NAME
  TOPIC_NAME=${TOPIC_NAME:-jatopic}

  read -p "Set you Consumer Group Name: [cg_name_1] " CG_NAME
  CG_NAME=${CG_NAME:-cg_${TOPIC_NAME}}

  read -p "Do you want consumer to fetch data from beginning: [0-No, 1-Yes] " FETCH_FROM_BEGINNING
  FETCH_FROM_BEGINNING=${FETCH_FROM_BEGINNING:-1}

  if  [[ $FETCH_FROM_BEGINNING -gt 0 ]] # means 'YES'
  then
    echo "Consumer Group Fetching data from beginning"
    $KAFKA_HOME/bin/kafka-console-consumer.sh \
      --bootstrap-server $BROKER \
      --consumer-property group.id=$CG_NAME \
      --topic $TOPIC_NAME \
      --from-beginning
  else
    echo "By default, new consumer group will not fetch older messages that got pushed to the Kafka topic/queue before defining consumer group"
    $KAFKA_HOME/bin/kafka-console-consumer.sh \
      --bootstrap-server $BROKER \
      --consumer-property group.id=$CG_NAME \
      --topic $TOPIC_NAME
  fi
}

# 3.4 Get the details of a Specific Consumer Group
# This will help you to get an insight of which topics are associated with this consumer group
# i.e. multiple topics could be using the same consumer group
k_cg_describe(){
  read -p "Enter BROKER Name: [localhost:9092] " BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  echo "Execute <k_cg_list> to get the list of all consumer groups"
  read -p "Enter Consumer Group Name: " CONSUMER_GP
  CONSUMER_GP=${CONSUMER_GP:-test-consumer-group}

  $KAFKA_HOME/bin/kafka-consumer-groups.sh \
    --bootstrap-server $BROKER \
    --describe \
    --group $CONSUMER_GP
}

# 3.5 Get the list of all Active members in the Consumer Group
# In this simulation, there would be no active members as we might not kept running the producer and consumer
# To check for active members in CG,
# in Terminal-1, execute the <producer>,
# in Terminal-2, execute the <consumer>,then terminate the consumer
# in Terminal-1, keep the <producer> alive
# check the active member now. If you find an active member
# if you terminate <producer>, you might not find any active members
# Ref: https://dbmstutorials.com/kafka/kafka-consumer-groups.html

k_cg_active_members(){
  read -p "Enter BROKER Name: [localhost:9092] " BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}   # Setting the default BROKER value

  echo "Execute <k_cg_list> to get the list of all consumer groups"
  read -p "Enter Consumer Group Name: " CONSUMER_GP
  CONSUMER_GP=${CONSUMER_GP:-test-consumer-group}

  read -p "Do you want to enable Verbose Mode [0-No, 1-Yes]: " CG_VERBOSE
  CG_VERBOSE=${CG_VERBOSE:-0}

  if [[ $CG_VERBOSE -gt 0 ]] # yes, enable verbose
  then
    $KAFKA_HOME/bin/kafka-consumer-groups.sh \
      --bootstrap-server $BROKER \
      --describe \
      --group $CONSUMER_GP \
      --members \
      --verbose
  else
    $KAFKA_HOME/bin/kafka-consumer-groups.sh \
      --bootstrap-server $BROKER \
      --describe \
      --group $CONSUMER_GP \
      --members
  fi
}

#================================================================================================================
# Step-4: Kafka Broker
# Basically, a broker in Kafka is modeled as KafkaServer, which hosts topics.
# Here, given topics are always partitioned across brokers
# Ref: https://data-flair.training/blogs/kafka-broker/

#4.1 Get the details of a Kafka broker
k_broker_describe(){
  read -p "Enter BROKER Name: [localhost:9092] " BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}

  read -p "Enter Your Broker Entity ID(alias Name) [0,1 etc In Numeric Format]: " BROKER_ENTITY_ID
  BROKER_ENTITY_ID=${BROKER_ENTITY_ID:-0}

  if [[ $BROKER_ENTITY_ID -eq 0 ]]
  then
    echo "Fetching the details of Current Dynamic Broker Configs"
  fi

  $KAFKA_HOME/bin/kafka-configs.sh \
    --bootstrap-server $BROKER \
    --entity-type brokers \
    --entity-name $BROKER_ENTITY_ID \
    --describe
}


# 4.2 Altering Kafka Broker- Adding a Configuration in a Kafka Broker
k_broker_alter_log_cleaner_bg_threads(){
  read -p "Enter BROKER Name: [localhost:9092] " BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}

  read -p "Do you want to alter all the existing Broker's Configuration in the cluster: [0-No/Just a Single one, 1-Yes/All]" ALL_BROKER
  ALL_BROKER=${ALL_BROKER:-0}

  read -p "How Many Log Cleaner Background Threads you want to have [1-100]: " LOG_CLEANER_BG_THREADS
  LOG_CLEANER_BG_THREADS=${LOG_CLEANER_BG_THREADS:-2}

  if [[ $ALL_BROKER -lt 1 ]] # a single broker
  then
    read -p "Enter Your Broker Entity ID(alias Name) [0,1 etc In Numeric Format]: " BROKER_ENTITY_ID
    $KAFKA_HOME/bin/kafka-configs.sh \
      --bootstrap-server $BROKER \
      --entity-type brokers \
      --entity-name $BROKER_ENTITY_ID \
      --alter \
      --add-config log.cleaner.threads=$LOG_CLEANER_BG_THREADS
  else  # All Broker
    $KAFKA_HOME/bin/kafka-configs.sh \
      --bootstrap-server $BROKER \
      --entity-type brokers \
      --alter \
      --add-config log.cleaner.threads=$LOG_CLEANER_BG_THREADS
  fi

  read -p "Do you want this configuration remains [0-No, 1-Yes]: " KEEP_CONFIGURATION
  KEEP_CONFIGURATION=${KEEP_CONFIGURATION:-1}
  if [[ $KEEP_CONFIGURATION -lt 1 ]] # 0 # No, Delete the current configuration
  then
    echo "Cleaning the Newly Created Configuration"
    k_broker_del_config
  fi
}

# 4.3 Delete a broker configuration
k_broker_del_config(){
  read -p "Enter BROKER Name: [localhost:9092] " BROKER
  BROKER=${BROKER:-$DEFAULT_BROKER}

  read -p "Do you want to remove the configuration for all Brokers in the cluster: [0-No/Just a single broker, 1-Yes/All]: " ALL_BROKER
  ALL_BROKER=${ALL_BROKER:-0}

  read -p "Enter the Configuration Name you want to delete: " CONFIG_NAME
  CONFIG_NAME=${CONFIG_NAME:-log.cleaner.threads}

  if [[ $ALL_BROKER -lt 1 ]] # 0 # A Single Broker
  then
    read -p "Enter Your Broker Entity ID (alias Name) [0,1 etc In Numeric Format]: " BROKER_ENTITY_ID
    $KAFKA_HOME/bin/kafka-configs.sh \
      --bootstrap-server $BROKER \
      --entity-type brokers \
      --entity-name $BROKER_ENTITY_ID \
      --alter \
      --delete-config $CONFIG_NAME
  else # 1 # All Brokers
    $KAFKA_HOME/bin/kafka-configs.sh \
      --bootstrap-server $BROKER \
      --entity-type brokers \
      --alter \
      --delete-config $CONFIG_NAME
  fi
}

# 4.4 Restart Kafka Broker
k_broker_restart(){
  echo "Restarting Kafka to make the effect of configuration changes ..."
  sudo systemctl restart kafka
}

















