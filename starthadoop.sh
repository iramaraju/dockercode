#!/bin/bash
# Author:Ram Indukuri - Knoldus Inc.
# Purpose:      Remove old data, remove logs, format Hadoop if firstboot, start hadoop dfs, datanode 
# Key Files:    /home/hadoop/hadoop/start.sh
#               crontab boot entry
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/core-site.xml
#               /usr/local/hadoop/stage/hadoopXXX/etc/hadoop/hdfs-site.xml  ## Check if the data.dir directories are rightly pointed to valid places with access
# MASTER MASTER MASTER MASTER with hadoop
# execute if script is run after booting
#       hadoop-daemon.sh stop datanode  #       stop-dfs.sh
# Slave with  hadoop
source /home/hadoop/.bashrc
dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Executing HADOOP Script:"$dt > /home/hadoop/hadoop/out.txt
echo "As user:"$USER > /home/hadoop/hadoop/out.txt
#  set variables
ec2-describe-tags > /home/hadoop/hadoop/tags
ec2-describe-tags | grep `wget -q -O - http://instance-data/latest/meta-data/instance-id` | grep SparkMaster | awk '{print $5}' > /home/hadoop/hadoop/masterdef
master=`cat /home/hadoop/hadoop/masterdef`
hadoopmaster=`var2=${master:8};var3=${var2%:7077};echo $var3`
echo $master >> /home/hadoop/hadoop/out.txt
echo $hadoopmaster >> /home/hadoop/hadoop/out.txt

# Copy Hadoop Here
rsync -arvce "ssh -o StrictHostKeyChecking=no" $hadoopmaster:/usr/local/hadoop/stage/hadoop-2.7.2  /usr/local/hadoop/stage/  >> /home/hadoop/hadoop/out.txt
/home/hadoop/hadoop/sbin/hadoop-daemon.sh stop datanode >> /home/hadoop/hadoop/out.txt

#First Boot or Reboot
FLAG="/home/hadoop/hadoop/firstboot"
if [ ! -f $FLAG ]; then

   echo "Clean UP" >> /home/hadoop/hadoop/out.txt
        # Clean Directories and format datanode
        rm -rf /home/hadoop/hadoop/logs/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs2/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs3/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs4/*
        rm -rf /usr/local/hadoop/hadoopdata/hdfs/namenode/*
        /home/hadoop/hadoop/bin/hdfs datanode -format
   touch $FLAG
else
   echo "Do nothing" >> /home/hadoop/hadoop/out.txt
fi

#Start Hadoop Datanode and then Finally Spark Worker
/home/hadoop/hadoop/sbin/hadoop-daemon.sh start datanode >> /home/hadoop/hadoop/out.txt

echo "End of  Script" >> /home/hadoop/hadoop/out.txt
