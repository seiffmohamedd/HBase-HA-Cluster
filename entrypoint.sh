#!/bin/bash

case $(hostname) in
  master11|master22|master33)
    NODE_TYPE="master"
    ;;
  hmaster1|hmaster2)
    NODE_TYPE="hmaster"
    ;;
  regionserver1|regionserver2)
    NODE_TYPE="regionserver"
    ;;
  *)
    NODE_TYPE="worker"
    ;;
esac

sudo service ssh start

if [[ $NODE_TYPE == "master" ]]; then
  mkdir -p $ZOOKEEPER_HOME/data
  case $(hostname) in
    master11) echo "1" > $ZOOKEEPER_HOME/data/myid ;;
    master22) echo "2" > $ZOOKEEPER_HOME/data/myid ;;
    master33) echo "3" > $ZOOKEEPER_HOME/data/myid ;;
  esac

  if [[ $(hostname) == "master11" ]]; then
    $ZOOKEEPER_HOME/bin/zkServer.sh start
    hdfs --daemon start journalnode
    hdfs namenode -initializeSharedEdits -force
    hdfs namenode -format
    hdfs zkfc -formatZK -force
    hdfs --daemon start namenode
    hdfs --daemon start zkfc
    sleep 40
    while true; do
      if jps | grep -q 'NameNode' && jps | grep -q 'ZKFailoverController'; then
        echo "NameNode and ZKFailoverController are running on master11."
        break
      fi
      echo "Waiting for NameNode and ZKFailoverController to start..."
      sleep 5
    done
  else
    sleep 10
    $ZOOKEEPER_HOME/bin/zkServer.sh start
    hdfs --daemon start journalnode
    hdfs namenode -bootstrapStandby -force
    hdfs --daemon start namenode
    hdfs --daemon start zkfc
  fi
  
  yarn --daemon start resourcemanager

elif [[ "$HOSTNAME" == *"hmaster"* ]]; then

        sleep 20
        echo "Starting HBase Master on $HOSTNAME..."
        # hbase master start
        hbase-daemon.sh start master
        echo "HBase Master started on $HOSTNAME."

elif [[ "$HOSTNAME" == *"regionserver"* ]]; then
        sleep 20
        echo "Starting HBase RegionServer on $HOSTNAME..."
        # hbase regionserver start
          hdfs --daemon start datanode
          yarn --daemon start nodemanager
        hbase-daemon.sh start regionserver
        echo "HBase RegionServer started on $HOSTNAME."

else
  echo "hello"
#   hdfs --daemon start datanode
#   yarn --daemon start nodemanager
fi

sleep infinity