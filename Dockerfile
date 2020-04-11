FROM openjdk:8u232-jdk

LABEL maintainer="jonathanlichi@gmail.com"
ARG ZK_VERSION=3.6.0
WORKDIR /tmp

# change apt source
# uncomment if needed
# RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
#   echo "deb http://mirrors.163.com/debian/ stretch main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb http://mirrors.163.com/debian/ stretch-updates main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb http://mirrors.163.com/debian/ stretch-backports main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb-src http://mirrors.163.com/debian/ stretch main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb-src http://mirrors.163.com/debian/ stretch-updates main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb-src http://mirrors.163.com/debian/ stretch-backports main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib">>/etc/apt/sources.list && \
#   echo "deb-src http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib">>/etc/apt/sources.list 

RUN apt-get update && apt-get install -y wget iputils-ping lsof
RUN wget https://downloads.apache.org/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz
RUN tar -xzvf apache-zookeeper-${ZK_VERSION}-bin.tar.gz -C / && mv /apache-zookeeper-${ZK_VERSION}-bin /zookeeper


COPY scripts/start-zookeeper.sh /
COPY conf/zookeeper-env.sh /zookeeper/conf
RUN chmod +x /start-zookeeper.sh && chmod +x /zookeeper/conf/zookeeper-env.sh

# change time zone
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
EXPOSE 2181 2888 3888

RUN rm -rf /tmp
WORKDIR /
ENTRYPOINT ["/start-zookeeper.sh"]