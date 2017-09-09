wget http://apache.otenet.gr/dist/tez/0.8.5/apache-tez-0.8.5-src.tar.gz && \
tar -xvzf apache-tez-0.8.5-src.tar.gz && \
rm apache-tez-0.8.5-src.tar.gz

cd apache-tez-0.8.5-src/build-tools/ && \
set -ex && \
wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz && \
tar -xzvf protobuf-2.5.0.tar.gz && \
cd protobuf-2.5.0 && ./configure --prefix=/usr && make && make install && \


# cd apache-tez-0.8.5-src/ &&\
#mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true

