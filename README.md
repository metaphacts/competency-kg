# Competency Knowledge Graph

The Competency Knowledge Graph is an effort to represent the broad field of artificial intelligence in a single knowledge graph. The idea is to describe the technical perspective (methods, tasks, models, metrics, ..) as well as the business perspective (use cases, sectors, business units, ..) in order to bridge the gap between theory and practice. Potential use cases of this graph may be the identification of relevant use cases for a given task, or the discovery of methods to solve a certain problem.

## Getting Started
### App Deployment
To deploy the app, include the folder `competency-kg-app` as volume in the `/apps` directory (if using docker). Alternatively, you can upload a zipped version of the folder `competency-kg-app` via Admin:Apps in your metaphactory instance.

### Data
The app currently uses two data sources:
- The [Computer Science Ontology](https://cso.kmi.open.ac.uk/)
- The [KMI ScholKG ontology](https://scholkg.kmi.open.ac.uk/)

To import the data, do the following:

a) For BlazeGraph

1. Make sure that BlazeGraph has enough RAM to process the file upload. The easiest way to do that is adding the following lines to the `services` section of the `docker-compose.overwrite.yml` in your deployment:
```
blazegraph:
    environment:
       - JAVA_OPTS=-Xmx4g
```
Hint: Restart your metaphactory instance (if it is running) to load the updated configuration.

2. Check that your metaphactory instance is running, then execute `/bin/sh run_import_blazegraph.sh <deployment-name>` where `<deployment-name>` should be replaced with the name of your metaphactory deployment. The import may take several minutes.

b) For GraphDB

1. Make sure that GraphDB has enough RAM to process the file upload. The easiest way to do that is adding the following lines to the `services` section of the `docker-compose.overwrite.yml` in your deployment:
```
graphdb:
    mem_limit: 6g
```

2. Check that your metaphactory instance is running, then execute `/bin/sh run_import_graphdb.sh <deployment-name>` where `<deployment-name>` should be replaced with the name of your metaphactory deployment. The import may take up to thirty minutes (even though the script finishes earlier).

### KMI Ontology Visualisation
The KMI ontology is represented using domain statements based on RDF lists. This notation can not be visualised with metaphactory and Ontodia. Further, the ontology is not using skos-ontology. To adapt the ontology, run the following queries:

#### Transform KMI ontology to SKOS Concept Scheme
Add skos:Concept statements:
```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology#> {
    ?kmiClass a skos:Concept .
    
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology#> {
    ?kmiClass a owl:Class .
}}
```

and add skos:broader statements:
```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology#> {
    ?kmiSub skos:broader ?kmiSuper .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology#> {
    ?kmiSub rdfs:subClassOf ?kmiSuper .
}}
```

#### Add SHACL shapes for domain and range constraints
```
PREFIX sh: <http://www.w3.org/ns/shacl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology#> {
 ?classShapeIri a sh:NodeShape ;
    sh:property [
      a sh:PropertyShape ;
      sh:path ?property ;
      sh:class ?range ;
  ] ;
    sh:targetClass ?targetClass .
  }}
WHERE {
  ?property rdfs:range ?range .
  ?property rdfs:domain ?union .
  ?union owl:unionOf ?listStart .
  ?listStart rdf:rest*/rdf:first ?targetClass .
  BIND ( IRI(CONCAT(STR(?targetClass), "Shape")) as ?classShapeIri)
}
```

#### Transform KMI reification into RDF-star
Add RDF-star triples:
```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX kmi-ont: <http://scholkg.kmi.open.ac.uk/aikg/ontology#>
PREFIX prov: <http://www.w3.org/ns/prov#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource/> {
  ?s ?p ?o .
  <<?s ?p ?o>> ?stmt_pred ?stmt_obj .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource/> {
?stmt a kmi-ont:Statement;
  rdf:subject ?s ;
  rdf:predicate ?p ;
  rdf:object ?o ;
  ?stmt_pred ?stmt_obj .
    FILTER ( ?stmt_pred IN (kmi-ont:hasSupport, prov:wasDerivedFrom, prov:wasGeneratedBy))
}}
```

and remove reification statements:
```
PREFIX kmi-ont: <http://scholkg.kmi.open.ac.uk/aikg/ontology#>

DELETE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource/> {
  ?stmt ?p ?o .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource/> {
?stmt a kmi-ont:Statement;
  ?p ?o .
}}
```