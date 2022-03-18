#!/bin/bash
# This Kafka Aliases is developed by Jahidul Arafat
# Architect at Oracle Corporation
# Technology Solution and Cloud

export DEFAULT_KAFKA_HOME=/usr/local/kafka
export DEFAULT_BOOTSTRAP="localhost:9092"
export DEFAULT_BROKER="localhost:9092" # however you could have multiple brokers too. In this case, list all those broker with comma(,) seperated i.e. "localhost:9092,localhost:9093,localhost:9094"


alias k_list_topics="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP --list"
#alias k-create-topic="$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server $BOOTSTRAP--replication-factor 1 --partitions 1 --topic"

k_create_topic(){
        read -p "Enter Kafka Topic Name: " TOPIC_NAME
        TOPIC_NAME=${TOPIC_NAME:-jatopic}

        read -p "Replicaton Factor [1-3]:" REP_FACTOR
        REP_FACTOR=${REP_FACTOR:-1}

        read -p "Partitions [1-3]:" PARTITION
        PARTITION=${PARTITION:-1}

        $KAFKA_HOME/bin/kafka-topics.sh \
                --create \
                --bootstrap-server $DEFAULT_BOOTSTRAP \
                --replication-factor $REP_FACTOR \
                --partitions $PARTITION \
                --topic $TOPIC_NAME
}

k_delete_topic(){
        read -p "Enter Kafka Topic Name [If you want to delete multiple topic of a name i.e. test-topic-1, test-topic-2 use test-* or test*]: " TOPIC_NAME
        read -p "Enter BROKER Name: [localhost:9092]" BROKER
        BROKER=${BROKER:-$DEFAULT_BROKER}

        $KAFKA_HOME/bin/kafka-topics.sh \
                --bootstrap-server $BROKER \
                --delete \
                --topic $TOPIC_NAME

}
