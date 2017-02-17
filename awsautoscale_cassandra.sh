#!/bin/bash
# Author:Ram Indukuri - Knoldus Inc.
# Purpose:      Remove data from cassandra if firstboot, else start cassandra fist node
# Key Files:    /usr/local/cassandra/stage/apache-cassandraxxxx/startcassandra.sh
#               crontab boot entry
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/core-site.xml
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/hdfs-site.xml  ## Check if the data.dir directories are rightly pointed to valid places with access
# STARTS  CASSANDRA First Node

source /root/.bashrc
dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Executing ELSSIE booting Script for Cassandra:"$dt > /root/cassandra/out.txt

# Replace cassandra.yaml with Tagged list of Seeds # Ex: "<ip1>,<ip2>,<ip3>"
myaddress=`wget -q -O - http://instance-data/latest/meta-data/local-ipv4`
ec2-describe-tags | grep `wget -q -O - http://instance-data/latest/meta-data/instance-id` | grep seeds | awk '{print $5}' > /root/cassandra/seeds
seeds=`cat /root/cassandra/seeds`
sed -i "/- seeds:/c\ \ \ \ \  - seeds: \"${seeds}\""   /root/cassandra/conf/cassandra.yaml
sed -i "/listen_address: /c\listen_address: ${myaddress}"   /root/cassandra/conf/cassandra.yaml

#First Boot or Reboot
FLAG="/root/cassandra/firstbooted"
if [ ! -f $FLAG ]; then
        # Clean Directories and format datanode
        echo "It is a First Boot .........." >> /root/cassandra/out.txt
        rm -rf  /usr/local/cassandra/cassandradata/cass1/data/*
        rm -rf  /usr/local/cassandra/cassandradata/cass2/data/*
        rm -rf  /usr/local/cassandra/cassandradata/cass3/data/*
        rm -rf  /usr/local/cassandra/cassandradata/cass/commitlog/*
        rm -rf  /usr/local/cassandra/cassandradata/cass/saved_caches/*
        rm -rf  /usr/local/cassandra/cassandradata/cass/hints/*
   touch $FLAG
else
   echo "It is a Reboot .........." >> /root/cassandra/out.txt
fi

#Start Cassandra
/root/cassandra/bin/cassandra  >> /root/cassandra/out.txt
echo "End of  Script" >> /root/cassandra/out.txt
