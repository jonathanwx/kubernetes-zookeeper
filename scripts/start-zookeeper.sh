#!/usr/bin/env bash

HOST=$(hostname -s)
DOMAIN=$(hostname -d)
SERVERS=1

if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
  NAME=${BASH_REMATCH[1]}
  ORD=${BASH_REMATCH[2]}
else
  echo "Fialed to parse name and ordinal of Pod"
  exit 1
fi

MY_ID=$((ORD + 1))

function create_config() {
  rm -rf /zookeeper/conf/zoo.conf
  cp /zookeeper/conf/zoo_sample.cfg /zookeeper/conf/zoo.cfg
  echo "" >>/zookeeper/conf/zoo.cfg
  if [ "${REPLICAS}" != "" ] && [ "${REPLICAS}" != "1" ]; then

    for ((i = 1; i <= ${REPLICAS}; i++)); do
      SERVER_STR="server.${i}=${NAME}-$((i - 1))"
      if [ "${DOMAIN}" != "" ]; then
        SERVER_STR="${SERVER_STR}.${DOMAIN}"
      fi
      echo "${SERVER_STR}:2888:3888" >>/zookeeper/conf/zoo.cfg
    done
    mkdir -p /zookeeper/data/${MY_ID}
    rm -rf /zookeeper/data/${MY_ID}/myid
    echo "${MY_ID}" >>/zookeeper/data/${MY_ID}/myid
    sed -i "s/^dataDir=.*$/dataDir=\/zookeeper\/data\/${MY_ID}/g" /zookeeper/conf/zoo.cfg
    sed -i "s/^ZOO_LOG_DIR=.*$/ZOO_LOG_DIR=\"\/zookeeper\/log\/${MY_ID}\"/g" /zookeeper/conf/zookeeper-env.sh
  else
    sed -i "s/^dataDir=.*$/dataDir=\/zookeeper\/data/g" /zookeeper/conf/zoo.cfg
    sed -i "s/^ZOO_LOG_DIR=.*$/ZOO_LOG_DIR=\/zookeeper\/log/g" /zookeeper/conf/log4j.properties
  fi
}

create_config && /zookeeper/bin/zkServer.sh start-foreground
