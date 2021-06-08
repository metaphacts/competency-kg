#!/bin/sh

DEPLOYMENT_NAME=$1
if [ -z "$DEPLOYMENT_NAME" ]
then
      echo "Pass the deployment name of your metaphactory instance as argument!"
      exit 1
fi

# copying import folder to blazegraph docker
docker cp import ${DEPLOYMENT_NAME}-blazegraph:/blazegraph-data/
# triggering download and import of data
docker exec -uroot ${DEPLOYMENT_NAME}-blazegraph bash -c 'cd /blazegraph-data/import && bash import_data.sh'
# cleaning up
docker exec -uroot ${DEPLOYMENT_NAME}-blazegraph rm -rf /blazegraph-data/import