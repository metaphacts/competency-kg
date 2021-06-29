#!/bin/sh

DEPLOYMENT_NAME=$1
if [ -z "$DEPLOYMENT_NAME" ]
then
      echo "Pass the deployment name of your metaphactory instance as argument!"
      exit 1
fi

IMPORT_FOLDER=/opt/graphdb/home/graphdb-import

# copying data preparation file to graphdb docker
docker exec -uroot ${DEPLOYMENT_NAME}-graphdb mkdir -p ${IMPORT_FOLDER}
docker cp prepare_data.sh ${DEPLOYMENT_NAME}-graphdb:${IMPORT_FOLDER}/
# triggering download of data
docker exec -uroot ${DEPLOYMENT_NAME}-graphdb bash -c "cd ${IMPORT_FOLDER} && bash prepare_data.sh"
# triggering import of data
docker exec -uroot ${DEPLOYMENT_NAME}-graphdb curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"fileNames": ["CSO.3.2.ttl"], "importSettings": {"context": "http://cso.kmi.open.ac.uk/"}}' http://graphdb:7200/rest/data/import/server/metaphactory
docker exec -uroot ${DEPLOYMENT_NAME}-graphdb curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"fileNames": ["kmi-ontology.ttl"], "importSettings": {"context": "http://scholkg.kmi.open.ac.uk/aikg/ontology#"}}' http://graphdb:7200/rest/data/import/server/metaphactory
docker exec -uroot ${DEPLOYMENT_NAME}-graphdb curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"fileNames": ["kmi-data.ttl"], "importSettings": {"context": "http://scholkg.kmi.open.ac.uk/aikg/resource/"}}' http://graphdb:7200/rest/data/import/server/metaphactory