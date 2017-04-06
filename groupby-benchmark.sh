#!/bin/bash -l

#SBATCH -p debug
#SBATCH -N 4
#SBATCH -n 4
#SBATCH -c 24
#SBATCH -t 00:15:00
#SBATCH -J GroupBy
#SBATCH -e GroupBy-%j.err
#SBATCH -o GroupBy-%j.out
#SBATCH -L SCRATCH   #Job requires $SCRATCH file system
#SBATCH -C haswell   #Use Haswell nodes
#SBATCH --image=docker:nchaimov/spark161-shifter:v3
#SBATCH --volume=/scratch1/scratchdirs/nchaimov/backingFile2:/mnt:perNodeCache=size=25G

export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR="/global/homes/n/nchaimov/groupby-shifter-test/conf"
export MASTER=`hostname`

NUM_NODES=16 
CORES_PER_NODE=32
export SPARK_WORKER_CORES=32

KVP_PER_PARTITION=1000
PARTITIONS_PER_CORE=4
VALUE_BYTES=8
SEED=50

TOTAL_EXECUTOR_CORES=$(( $NUM_NODES * $CORES_PER_NODE ))
NUM_PARTITIONS=$(( $TOTAL_EXECUTOR_CORES * $PARTITIONS_PER_CORE ))

echo ">>>> Starting servers"
srun -n $NUM_NODES -N $NUM_NODES -c $CORES_PER_NODE shifter $SPARK_HOME/sbin/start-cluster.sh $MASTER &

sleep 10 # wait for master to start up

echo ">>>>> Running GroupByTest"
shifter $SPARK_HOME/bin/spark-submit --master spark://$MASTER:7077 --total-executor-cores $TOTAL_EXECUTOR_CORES --conf spark.scheduler.minRegisteredResourcesRatio=1.0 $SPARK_HOME/instrumentation-benchmarks/GroupBy/target/scala-2.10/groupbytest_2.10-1.0.jar $NUM_PARTITIONS $KVP_PER_PARTITION $VALUE_BYTES $NUM_PARTITIONS $SEED

echo ">>>>> Done"
