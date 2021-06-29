#!/bin/sh

printf "\n### %s ###\n\n" "Uploading CS ontology into named graph http://cso.kmi.open.ac.uk/"
curl -X POST --data-binary @import_cso.xml --header 'Content-Type:application/xml' http://localhost:8080/blazegraph/dataloader

printf "\n### %s ###\n\n" "Uploading KMI ontology into named graph http://scholkg.kmi.open.ac.uk/aikg/ontology#"
curl -X POST --data-binary @import_kmi-ont.xml --header 'Content-Type:application/xml' http://localhost:8080/blazegraph/dataloader

printf "\n### %s ###\n\n" "Uploading KMI data into named graph http://scholkg.kmi.open.ac.uk/aikg/resource/ (may take some minutes!)"
curl -X POST --data-binary @import_kmi-data.xml --header 'Content-Type:application/xml' http://localhost:8080/blazegraph/dataloader

printf "\n### %s ###\n\n" "Data import successful"