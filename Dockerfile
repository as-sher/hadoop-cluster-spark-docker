FROM ubuntu:16.04

MAINTAINER kgiann78 <kgiann78@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget less nano git maven scala

# install hadoop 2.7.3
RUN wget http://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
    tar -xzvf hadoop-2.7.3.tar.gz && \
    mv hadoop-2.7.3 /usr/local/hadoop && \
    rm hadoop-2.7.3.tar.gz

# install spark 2.1.0 with hadoop 2.7 prebuilt
RUN wget https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.3.0-bin-hadoop2.7.tgz && \
    mv spark-2.3.0-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.3.0-bin-hadoop2.7.tgz

# install hive 2.1.0
RUN wget https://archive.apache.org/dist/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz && \
    tar -xzvf apache-hive-2.1.1-bin.tar.gz && \
    mv apache-hive-2.1.1-bin /usr/local/hive && \
    rm apache-hive-2.1.1-bin.tar.gz

RUN apt-get update && apt-get install -y build-essential



# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV HIVE_HOME=/usr/local/hive
ENV HIVE_CONF_DIR=/usr/local/hive/conf
ENV CLASSPATH=$CLASSPATH:/usr/local/hadoop/lib/*:.
ENV CLASSPATH=$CLASSPATH:/usr/local/hive/lib/*:.
ENV HADOOP_INSTALL=/usr/local/hadoop
ENV HADOOP_PREFIX=/usr/local/hadoop
ENV HADOOP_MAPRED_HOME=$HADOOP_INSTALL
ENV HADOOP_COMMON_HOME=$HADOOP_INSTALL
ENV HADOOP_HDFS_HOME=$HADOOP_INSTALL
ENV YARN_HOME=$HADOOP_INSTALL
ENV HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
ENV HADOOP_CONF_DIR=$HADOOP_INSTALL/etc/hadoop 
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin
ENV PATH=$PATH:$SPARK_HOME/bin
ENV TEZ_CONF_DIR=$HIVE_CONF_DIR
ENV TEZ_JARS=/usr/local/tez
ENV LIVY_DIR="/usr/local/lib/livy"
ENV LIVY_BIN="${LIVY_DIR}/bin"
ENV LIVY_CONF="${LIVY_DIR}/conf"

ENV PKG_PATH="incubator/livy/${LIVY_VERSION}-incubating/${LIVY_PKG_NAME}.zip"

#ENV HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*
ENV HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*:${HADOOP_CLASSPATH}:${JAVA_JDBC_LIBS}:${MAPREDUCE_LIBS}
ENV CLASSPATH=$CLASSPATH:${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

RUN apt-get install -y unzip

# install livy
RUN wget http://apachemirror.wuchna.com/incubator/livy/0.6.0-incubating/apache-livy-0.6.0-incubating-bin.zip && \
    unzip apache-livy-0.6.0-incubating-bin.zip && \
    mv apache-livy-0.6.0-incubating-bin /usr/local/lib/livy && \
    rm apache-livy-0.6.0-incubating-bin.zip

RUN mkdir /var/log/livy

RUN echo "LIVY_LOG_DIR=/var/log/livy" >> /usr/local/lib/livy/conf/livy-env.sh

RUN apt-get update 
RUN apt-get install -y vim

RUN echo "livy.spark.master = yarn" >> /usr/local/lib/livy/conf/livy.conf

RUN echo "livy.spark.deploy-mode = cluster" >> /usr/local/lib/livy/conf/livy.conf

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-env.sh $HADOOP_HOME/etc/hadoop/mapred-env.sh && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/start-hiveserver2.sh ~/start-hiveserver2.sh && \
    mv /tmp/stop-hiveserver2.sh ~/stop-hiveserver2.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/stop-hadoop.sh ~/stop-hadoop.sh && \
    mv /tmp/beeline-hs2-connection.xml $HIVE_CONF_DIR/beeline-hs2-connection.xml && \
    mv /tmp/hive-env.sh $HIVE_CONF_DIR/hive-env.sh && \
    mv /tmp/hive-site.xml $HIVE_CONF_DIR/hive-site.xml && \
    mv /tmp/spark-env.sh $SPARK_HOME/conf/spark-env.sh && \
    mv /tmp/tez-site.xml $TEZ_CONF_DIR/tez-site.xml && \
    mv /tmp/hive-init.sh ~/hive-init.sh
#    mv /tmp/.bowerrc ~/.bowerrc


RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x ~/stop-hadoop.sh && \
    chmod +x ~/start-hiveserver2.sh && \
    chmod +x ~/stop-hiveserver2.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh

# clone ThesisHiveSpatial
RUN git clone https://github.com/kgiann78/thesis-spatial.git

# build thesis-spatial
#RUN cd thesis-spatial && \
#    git checkout develop && \
#    git pull && \
#    mvn clean install


# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

RUN apt-get update && apt-get install -y libpostgresql-jdbc-java && \
	cd $HIVE_HOME/lib && \
	ln -s /usr/share/java/postgresql-jdbc4.jar

CMD [ "sh", "-c", "service ssh start; bash;"]
CMD bash /usr/local/lib/livy/bin/livy-server start
CMD bash /usr/local/hadoop/sbin/start-all.sh 


