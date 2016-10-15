FROM ubuntu:16.04
MAINTAINER Nicholas Chaimov <nchaimov@uoregon.edu>

RUN apt-get update && \
    apt-get upgrade -y && \
		apt-get install -y  software-properties-common dialog && \
		add-apt-repository ppa:webupd8team/java -y && \
		apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
		apt-get install -y oracle-java8-installer && \
		apt-get install oracle-java8-set-default && \
		apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get update && \
		apt-get install -y ant ivy cmake build-essential automake autoconf maven curl libtool zlib1g-dev lua-zlib lua-zlib-dev pkg-config libssl-dev apt-transport-https && \
		apt-get clean
		
RUN echo "deb https://dl.bintray.com/sbt/debian /" |  tee -a /etc/apt/sources.list.d/sbt.list && \
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823 && \
		apt-get update && \
		apt-get install -y sbt && \
		apt-get clean
		
RUN mkdir -p /opt

RUN cd /opt && \
    wget https://github.com/google/protobuf/archive/v2.5.0.tar.gz && \
		tar xvzf v2.5.0.tar.gz && \
		rm v2.5.0.tar.gz && \
		mv protobuf-2.5.0 protobuf && \
		cd protobuf && \
		wget https://github.com/google/googletest/archive/release-1.5.0.tar.gz && \
		tar xvzf release-1.5.0.tar.gz && \
		mv googletest-release-1.5.0 gtest && \
		./autogen.sh && \
		./configure --prefix=/usr && \
		make && \
		make install
		
RUN cd /opt && \
		wget http://mirrors.advancedhosters.com/apache/hadoop/common/hadoop-2.6.4/hadoop-2.6.4-src.tar.gz && \
		tar xvzf hadoop-2.6.4-src.tar.gz && \
		rm hadoop-2.6.4-src.tar.gz && \
		mv hadoop-2.6.4-src hadoop && \
		cd hadoop && \
		mvn clean package install -Pdist -Dtar -Dmaven.javadoc.skip=true -DskipTests -Pnative
		
ENV PATH /opt/hadoop/hadoop-dist/target/hadoop-2.6.4/bin:$PATH

RUN cd /opt && \
		git clone https://github.com/nchaimov/spark.git -b branch-2.0-shifter --depth 1 && \
		cd spark && \
		./build/mvn -Phadoop-2.6 -Dhadoop.version=2.6.4 -Pyarn -Phive -Phive-thriftserver -DskipTests package install
				
ENV PATH /opt/spark/bin:$PATH
ENV SPARK_HOME /opt/spark

RUN cd /opt/spark/instrumentation-benchmarks/GroupBy && \
    sbt package
		
