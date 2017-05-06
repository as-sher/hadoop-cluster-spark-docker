#!/bin/bash

# the default node number is 4
N=${1:-5}

# stop hadoop slave containers
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "stop hadoop-slave$i container..."
	i=$(( $i + 1 ))
done 

# stop hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "stop hadoop-master container..."
