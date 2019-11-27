FROM openjdk:8u102-jre

ENV CLASSPATH="/opt/kafka/libs/rename-topic.jar"
COPY kafka_2.11-0.11.0.0 /opt/kafka
RUN echo "Asia/shanghai" > /etc/timezone;
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
USER root
RUN chmod +x /opt/kafka/bin/kafka-mirror-maker.sh
ADD scripts/start.sh start.sh
ENTRYPOINT ["sh","start.sh"]
