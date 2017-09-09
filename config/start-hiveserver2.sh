#!/bin/bash

echo "starting metastore"

nohup hive --service metastore &
# > /tmp/hive/logs/metastore.log  &

sleep 5

echo "starting hiveserver2"
nohup hive --service hiveserver2 & 
# > /tmp/hive/logs/hiveserver2.log &

sleep 5

ps -ef | grep hive
