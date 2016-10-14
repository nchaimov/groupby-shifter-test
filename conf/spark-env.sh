#!/usr/bin/env bash

export SPARK_SCRATCH=/mnt
export SPARK_WORKDIR=$SPARK_SCRATCH

export SPARK_LOCAL_DIRS="$SPARK_SCRATCH/spark/`hostname`-local"
export SPARK_WORKER_DIR="$SPARK_WORKDIR/spark-work/`hostname`-work"
export SPARK_LOG_DIR="$SPARK_WORKDIR/spark-logs/`hostname`-logs"

export SPARK_MASTER_OPTS="-Dspark.deploy.spreadOut=false"
export SPARK_EXECUTOR_CORES=32
export SPARK_WORKER_CORES=32

export SPARK_LAUNCHER_JAVA_BIN="/usr/lib/jvm/java-8-oracle/bin/java"


