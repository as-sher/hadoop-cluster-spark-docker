#!/bin/bash

/root/start-hadoop.sh

#hadoop fs -mkdir /apps
hadoop fs -mkdir -p /apps/tez-0.8.5
hadoop fs -mkdir /tmp
hadoop fs -mkdir /user
#hadoop fs -mkdir /user/hive
hadoop fs -mkdir -p /user/hive/warehouse


hadoop fs -copyFromLocal /tmp/tez-0.8.5.tar.gz /apps/tez-0.8.5/
hadoop fs -put /root/thesis-spatial/thesis-thrift-server/src/main/resources/jars/ /

hadoop fs -chmod g+w /tmp
hadoop fs -chmod g+w /user/hive/warehouse
hadoop fs -chmod g+w /jars
hadoop fs -chmod g+x /apps/tez-0.8.5/tez-0.8.5.tar.gz

apt-get install -y postgresql
#apt-get install -y libpostgresql-jdbc-java
#cd $HIVE_HOME/lib && ls -s /usr/share/java/postgresql-jdbc4.jar
#chmod 644 /usr/share/java/postgresql-jdbc4.jar

echo "host all all 0.0.0.0 0.0.0.0 md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf

# start postgres service
service postgresql start

# Set password to user postgres before doing anything else:
# su -
# su - postgres
# psql postgres
# \password postgres
# set new password i.e. mynewsecretpassword
# \q


# Then you may change /etc/postgresql/9.5/main/pg_hba.conf line
# local   all             postgres                                peer
# to 
# local   all             postgres                                md5

# restart service
#service postgresql restart

# Create metastore database and hive user

# echo "CREATE DATABASE metastore; CREATE USER hive WITH PASSWORD 'hive_password'; GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;" | psql -U postgres

# finally
schematool -dbType postgres -initSchema

# upgrade metastore schema
# first check hive version
#ll /usr/local/hive/lib/ | grep hive-hwi
# note the x.x.x version of the file 
#
# su - postgres
# psql
# \i /usr/local/hive/scripts/metastore/upgrade/postgres/hive-schema-x.x.x..postgres.sql
