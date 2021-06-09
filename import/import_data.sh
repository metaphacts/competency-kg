#!/bin/sh

printf "\n### %s ###\n\n" "Downloading CSO and ScholKG data"
wget -q https://cso.kmi.open.ac.uk/download/version-3.2/CSO.3.2.ttl.zip
unzip -q CSO.3.2.ttl.zip && rm CSO.3.2.ttl.zip
echo "CSO data downloaded."

wget -q https://scholkg.kmi.open.ac.uk/aikg/ontology -O scholkg-ontology.ttl
wget -q https://scholkg.kmi.open.ac.uk/downloads/aikg.zip
unzip -q aikg.zip && rm aikg.zip && mv aikg.ttl scholkg-data.ttl
echo "ScholKG data downloaded."

printf "\n### %s ###\n\n" "Uploading CS ontology into named graph http://cso.kmi.open.ac.uk/"
curl -X POST --data-binary @import_cso.xml --header 'Content-Type:application/xml' http://localhost:8080/blazegraph/dataloader

printf "\n### %s ###\n\n" "Uploading ScholKG ontology and data into named graph http://scholkg.kmi.open.ac.uk/aikg/ (may take some minutes!)"
curl -X POST --data-binary @import_scholkg.xml --header 'Content-Type:application/xml' http://localhost:8080/blazegraph/dataloader

printf "\n### %s ###\n\n" "Data import successful"