#!/bin/bash
# Author:Ram Indukuri - Knoldus Inc.
# Purpose:      Remove old data, remove logs, format Hadoop if firstboot, start hadoop dfs, datanode and spark master + workder
# Key Files:    /usr/local/spark/stage/sparkXXX/start.sh
#               crontab boot entry
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/core-site.xml
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/hdfs-site.xml  ## Check if the data.dir directories are rightly pointed to valid places with access
# MASTER MASTER MASTER MASTER with spark and hadoop
# execute if script is run after booting
#       hadoop-daemon.sh stop datanode  #       stop-dfs.sh

source /root/.bashrc
dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Executing ELSSIE booting Script:"$dt > /root/spark/out.txt

# Replace Coresite.xml with correct host ip address
sparkmaster=`curl http://instance-data/latest/meta-data/local-ipv4`
sed -i "/<value>hdfs:\/\//c\<value>hdfs:\/\/${sparkmaster}:9000<\/value>" /root/hadoop/etc/hadoop/core-site.xml

#First Boot or Reboot
FLAG="/root/spark/firstbooted"
if [ ! -f $FLAG ]; then
        # Clean Directories and format datanode
        echo "It is a First Boot .........." >> /root/spark/out.txt
        rm -rf /root/hadoop/logs/*
        rm -rf /root/spark/logs/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs2/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs3/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs4/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs/namenodei/*
        /root/hadoop/bin/hdfs namenode -format -force
   touch $FLAG
else
   echo "It is a Reboot .........." >> /root/spark/out.txt
fi

#Start Hadoop File System, Datanode  and then Finally Spark Master and Worker
/root/hadoop/sbin/hadoop-daemon.sh start namenode >> /root/spark/out.txt
/root/hadoop/sbin/hadoop-daemon.sh start secondarynamenode >> /root/spark/out.txt
/root/hadoop/sbin/hadoop-daemon.sh start datanode >> /root/spark/out.txt
/usr/local/spark/stage/spark-2.0.0-bin-hadoop2.7/sbin/start-all.sh $master  >> /root/spark/out.txt

echo "End of  Script" >> /root/spark/out.txt
