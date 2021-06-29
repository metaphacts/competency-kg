#!/bin/sh

printf "\n### %s ###\n\n" "Downloading CSO and ScholKG data"
wget https://cso.kmi.open.ac.uk/download/version-3.2/CSO.3.2.ttl.zip
unzip -q CSO.3.2.ttl.zip && rm CSO.3.2.ttl.zip
# adding missing ontology statement to CSO ontology
printf "\n<http://cso.kmi.open.ac.uk/schema/cso#> a owl:Ontology ; <http://www.linkedmodel.org/1.2/schema/vaem#namespace> <http://cso.kmi.open.ac.uk/schema/cso#> .\n" >> CSO.3.2.ttl
echo "CSO data prepared."

wget https://scholkg.kmi.open.ac.uk/aikg/ontology -O kmi-ontology.ttl
# adding missing ontology statement to KMI ontology
printf "\n<http://scholkg.kmi.open.ac.uk/aikg/ontology#> a owl:Ontology ; <http://www.linkedmodel.org/1.2/schema/vaem#namespace> <http://scholkg.kmi.open.ac.uk/aikg/ontology#> .\n" >> kmi-ontology.ttl

wget https://scholkg.kmi.open.ac.uk/downloads/aikg.zip
unzip -q aikg.zip && rm aikg.zip && mv aikg.ttl kmi-data.ttl
echo "KMI data prepared."