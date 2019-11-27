if [ -n "$WHITE_LIST" ]; then
    WHITE_LIST="--whitelist $WHITE_LIST"
fi

if [ -n "$MESSAGE_HANDLER" ]; then
    MESSAGE_HANDLER="--message.handler $MESSAGE_HANDLER"
fi

if [ -n "$FROM_TOPIC_TO_TOPIC" ]; then
    FROM_TOPIC_TO_TOPIC="--message.handler.args $FROM_TOPIC_TO_TOPIC"
fi

if [ -n "$BLACK_LIST" ]; then
    BLACK_LIST="--blacklist $BLACK_LIST"
fi

if [ -n "$CONSUMER_COUNT" ]; then
    CONSUMER_COUNT="--num.streams $CONSUMER_COUNT"
fi

cat <<- EOF > /opt/kafka/bin/producer.properties
bootstrap.servers=${DESTINATION}
acks=1
batch.size=16384
client.id=mirror_maker_producer
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${USERNAME}" password="${PASSWORD}";
EOF

cat <<- EOF > /opt/kafka/bin/consumer.properties
bootstrap.servers=${SOURCE}
key.deserializer=org.apache.kafka.common.serialization.StringDeserializer
value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
group.id=${GROUP_ID}
partition.assignment.strategy=org.apache.kafka.clients.consumer.RoundRobinAssignor
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${USERNAME}" password="${PASSWORD}";
EOF

cd /opt/kafka/bin
sh kafka-mirror-maker.sh \
--consumer.config /opt/kafka/bin/consumer.properties \
--producer.config /opt/kafka/bin/producer.properties \
$CONSUMER_COUNT \
$WHITE_LIST \
$BLACK_LIST \
--message.handler com.opencore.RenameTopicHandler \
$FROM_TOPIC_TO_TOPIC \
# --offset.commit.interval.ms $OFFSET_COMMIT_INTERVAL
# --abort.on.send.failure $ABORT_ON_FAILURE
# --consumer.rebalance.listener="TODO?"
# --rebalance.listener.args="TODO?"
# --message.handler="TODO?"
# --message.handler.args="TODO?"

