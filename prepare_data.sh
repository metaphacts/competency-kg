#!/bin/sh

printf "\n### %s ###\n\n" "Downloading CSO and ScholKG data"
wget -O cso.ttl.zip https://cso.kmi.open.ac.uk/download/version-3.3/CSO.3.3.ttl.zip
unzip -q cso.ttl.zip && rm cso.ttl.zip
# adding missing ontology statement to CSO ontology
printf "\n<http://cso.kmi.open.ac.uk/schema/cso> a owl:Ontology ; <http://www.linkedmodel.org/1.2/schema/vaem#namespace> <http://cso.kmi.open.ac.uk/schema/cso#> .\n" >> cso.ttl
echo "CSO data prepared."

wget -O kmi-ontology.ttl https://scholkg.kmi.open.ac.uk/aikg/ontology
# adding missing ontology statement to KMI ontology
printf "\n<http://scholkg.kmi.open.ac.uk/aikg/ontology#> a owl:Ontology ; <http://www.linkedmodel.org/1.2/schema/vaem#namespace> <http://scholkg.kmi.open.ac.uk/aikg/ontology#> .\n" >> kmi-ontology.ttl

wget -O kmi-data.ttl.zip https://scholkg.kmi.open.ac.uk/downloads/aikg.zip
unzip -q kmi-data.ttl.zip && rm kmi-data.ttl.zip
echo "KMI data prepared."


printf "\n### %s ###\n\n" "Downloading dependent ontologies for Competency Ontology (ORG, FOAF,..)"
wget https://www.w3.org/ns/org.ttl
wget -O foaf.rdf http://xmlns.com/foaf/spec/index.rdf
wget -O aida.ttl http://aida.kmi.open.ac.uk/ontology
# adding missing ontology statement to AIDA ontology
printf "\n<http://aida.kmi.open.ac.uk/ontology> a owl:Ontology ; <http://www.linkedmodel.org/1.2/schema/vaem#namespace> <http://aida.kmi.open.ac.uk/ontology#> .\n" >> aida.ttl
wget -O induso.ttl http://aida.kmi.open.ac.uk/downloads/induso

echo "Dependent ontologies prepared."