# Hadoop and Spark cluster in Docker
This docker hadoop cluster is based on [kiwenlau/hadoop-cluster-docker](http://github.com/kiwenlau/hadoop-cluster-docker) but it also contains a spark distribution. 
The main idea is to run spark applications by using the yarn as master!

Information on the original hadoop-cluster-docker can be found here:

- Blog: [Run Hadoop Cluster in Docker Update](http://kiwenlau.com/2016/06/26/hadoop-cluster-docker-update-english/)

![alt tag](https://raw.githubusercontent.com/kiwenlau/hadoop-cluster-docker/master/hadoop-cluster-docker.png)

## Configuring yarn and mapreduce 2 in hdp 2.0

Because when runnning a spark-submit there were cases that run into memory issues, i.e. error messages like 'Container [pid=28920,containerID=container_XXX] 
is running beyond virtual memory limits. Current usage: 1.2 GB of 1 GB physical memory used; 2.2 GB of 2.1 GB virtual memory used. Killing container.',
the files yarn-site.xml and mapred-site.xml in the config directory have additional properties. You may need to configure yarn and mapreduce accordingly
to your needs.

In the following lines we explain the configuration that we followed here.

Based on [HOW TO PLAN AND CONFIGURE YARN AND MAPREDUCE 2 IN HDP 2.0](https://hortonworks.com/blog/how-to-plan-and-configure-yarn-in-hdp-2-0/) by Rohit Bakhshi in Hortonworks,
 in a Hadoop cluster, it’s vital to balance the usage of RAM, CPU and disk so that processing is not constrained by any one of these cluster resources.
As a general recommendation, we’ve found that allowing for 1-2 Containers per disk and per core gives the best balance for cluster utilization.
Each machine in our cluster has 48 GB of RAM. Some of this RAM should be reserved for Operating System usage. 
On each node, we’ll assign 40 GB RAM for YARN to use and keep 8 GB for the Operating System. 
The following property sets the maximum memory YARN can utilize on the node:

In yarn-site.xml add the lines:
```
<property>
	<name>yarn.nodemanager.resource.memory-mb</name>
	<value>40960</value>
</property>
```

Also, provide YARN guidance on how to break up the total resources available into Containers.
You do this by specifying the minimum unit of RAM to allocate for a Container.
We want to allow for a maximum of 20 Containers, and thus need (40 GB total RAM) / (20 # of Containers) = 2 GB minimum per container.

In yarn-site.xml add the lines:
``` 
<property>
	<name>yarn.scheduler.minimum-allocation-mb</name>
        <value>2048</value>
</property>
```
YARN will allocate Containers with RAM amounts greater than the yarn.scheduler.minimum-allocation-mb.

### CONFIGURING MAPREDUCE 2

MapReduce 2 runs on top of YARN and utilizes YARN Containers to schedule and execute its map and reduce tasks.
When configuring MapReduce 2 resource utilization on YARN, there are three aspects to consider:
* Physical RAM limit for each Map And Reduce task
* The JVM heap size limit for each task
* The amount of virtual memory each task will get

You can define how much maximum memory each Map and Reduce task will take.
Since each Map and each Reduce will run in a separate Container, 
these maximum memory settings should be at least equal to or more
than the YARN minimum Container allocation.

For our example cluster, we have the minimum RAM for a Container
(yarn.scheduler.minimum-allocation-mb) = 2 GB.
We’ll thus assign 4 GB for Map task Containers, and 8 GB for Reduce tasks Containers.

In mapred-site.xml add the lines:
```
<property>
        <name>mapreduce.map.memory.mb</name>
        <value>4096</value>
</property>
<property>
	<name>mapreduce.reduce.memory.mb</name>
        <value>8192</value>
</property>
```

Each Container will run JVMs for the Map and Reduce tasks. The JVM heap size 
should be set to lower than the Map and Reduce memory defined above, 
so that they are within the bounds of the Container memory allocated by YARN.

In mapred-site.xml add the lines:
```
<property>
        <name>mapreduce.map.java.opts</name>
        <value>-Xmx3072m</value>
</property>
<property>
        <name>mapreduce.reduce.java.opts</name>
        <value>-Xmx6144m</value>
</property>
```
The above settings configure the upper limit of the physical RAM that Map and Reduce tasks will use.
The virtual memory (physical + paged memory) upper limit for each Map and Reduce task is determined by the virtual 
memory ratio each YARN Container is allowed. This is set by the following configuration, and the default value is 2.1:

In yarn-site.xml add the lines:
```
<property>
	<name>yarn.nodemanager.vmem-pmem-ratio</name>
	<value>2.1</value>
</property>
```

Thus, with the above settings on our example cluster, each Map task will get the following memory allocations with the following:
* Total physical RAM allocated = 4 GB
* JVM heap space upper limit within the Map task Container = 3 GB
* Virtual memory upper limit = 4*2.1 = 8.2 GB

With YARN and MapReduce 2, there are no longer pre-configured static slots for Map and Reduce tasks.
The entire cluster is available for dynamic resource allocation of Maps and Reduces as needed by the job.
In our example cluster, with the above configurations, YARN will be able to allocate on each node up to
10 mappers (40/4) or 5 reducers (40/8) or a permutation within that.

## 5 Nodes Hadoop Cluster

### 1. clone github repository

```
git clone https://github.com/kgiann78/hadoop-cluster-docker
```
### 2. Build docker file

```
sudo docker build -t kgiann78/msc-thesis-hadoop-spark:1.0 .
```

In case built the image with a different name, don't forget to change the name also at the start-container.sh file.

### 3. create hadoop network

```
sudo docker network create --driver=bridge hadoop
```

### 4. start container

```
cd hadoop-cluster-docker
sudo ./start-container.sh
```

**output:**

```
start hadoop-master container...
start hadoop-slave1 container...
start hadoop-slave2 container...
start hadoop-slave3 container...
start hadoop-slave4 container...
root@hadoop-master:~# 
```
- start 5 containers with 1 master and 4 slaves
- you will get into the /root directory of hadoop-master container

### 5. start hadoop

```
./start-hadoop.sh
```

### 6. run wordcount

In order to test the hadoop installation we run a simple mapreduce test

```
./run-wordcount.sh
```

**output**

```
input file1.txt:
Hello Hadoop

input file2.txt:
Hello Docker

wordcount output:
Docker    1
Hadoop    1
Hello    2
```
### 7. test spark installation

In order to test the spark installation we run a spark example with spark-submit*

```
spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master yarn \
  --deploy-mode client \
  /usr/local/spark/examples/jars/spark-examples_2.11-2.1.0.jar  \
  100
```

## Arbitrary size Hadoop cluster

### 1. pull docker images and clone github repository

do 1~3 like section A

### 2. rebuild docker image

```
sudo ./resize-cluster.sh 5
```
- specify parameter > 1: 2, 3..
- this script just rebuild hadoop image with different **slaves** file, which pecifies the name of all slave nodes


### 3. start container

```
sudo ./start-container.sh 5
```
- use the same parameter as the step 2

### 4. run hadoop cluster 

do 5~6 like section A

