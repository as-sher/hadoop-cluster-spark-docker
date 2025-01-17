#!/bin/bash

# the default node number is 3
N=${1:-3}


# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
		-p 10000:10000 \
		-p 4040:4040 \
                -p 8998:8998 \
		-p 7070:7070 \
		-p 7077:7077 \
		-p 8033:8033 \
		-p 8032:8032 \
		-p 8031:8031 \
		-p 8030:8030 \
                --name hadoop-master \
                --hostname hadoop-master \
                hadoop-spark-livy:0.2 &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                hadoop-spark-livy:0.2 &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
sudo docker exec -it hadoop-master bash
