# Competency Knowledge Graph
The CompetencyKG is a knowledge graph and an application to model and manage competencies in a business environment. An organisation can use it to describe what kind of competencies are relevant and how they are distributed over the organisation. These descriptions can be applied in several use cases like `expert search` or `project recommendation`. Refer to our [Wiki](https://github.com/metaphacts/competency-kg/wiki) for more information.

## Setup
This is an app for the [metaphactory platform](https://metaphacts.com/product). We recommend to use the docker-based setup with GraphDB for this app.

### App Deployment
To deploy the app, include the folder `competency-kg-app` as volume in the `/apps` directory (if using docker). Alternatively, you can (later) upload a zipped version of the folder `competency-kg-app` via Admin:Apps in your metaphactory instance.

### CSO-Classifier
We use the [CSO classifier](https://github.com/angelosalatino/cso-classifier) to enhance data that has been entered into the graph. To run a local version of this classifier, add the following configuration as additional `service` to your `docker-compose.overwrite.yml`:

```
csoclassifier:
  container_name: "${COMPOSE_PROJECT_NAME}-csoclassifier"
  image: "nheist/cso_classifier_rest_api:0.1.2"
  networks:
    - metaphactory_network
```

### Data
The app currently uses two main data sources to model competencies:
- The [Computer Science Ontology](https://cso.kmi.open.ac.uk/)
- The [KMI ScholKG ontology](https://scholkg.kmi.open.ac.uk/)

We use a GraphDB setup to work with the data. To import the data, do the following:


1. Make sure that GraphDB has enough RAM to process the file upload. The easiest way to do that is adding the following lines to the `services` section of the `docker-compose.overwrite.yml` in your deployment:

```
graphdb:
    mem_limit: 6g
```

2. Check that your metaphactory instance is running, then execute `/bin/sh run_import_graphdb.sh <deployment-name>` where `<deployment-name>` should be replaced with the name of your metaphactory deployment. The import may take up to thirty minutes (even though the script finishes earlier).

### GraphDB Configuration
The following query sets up a fulltext-search based on Lucene.

Create the Lucene connector:

```
PREFIX :<http://www.ontotext.com/connectors/lucene#>
PREFIX inst:<http://www.ontotext.com/connectors/lucene/instance#>
INSERT DATA {
   inst:lucene_connector :createConnector '''
{
  "fields": [
    {
      "fieldName": "label",
      "propertyChain": [
        "http://www.w3.org/2000/01/rdf-schema#label"
      ],
      "indexed": true,
      "stored": true,
      "analyzed": true,
      "multivalued": true,
      "ignoreInvalidValues": false,
      "facet": true
    }
  ],
  "languages": [],
  "types": [
    "http://scholkg.kmi.open.ac.uk/aikg/ontology#Material",
    "http://scholkg.kmi.open.ac.uk/aikg/ontology#Method",
    "http://scholkg.kmi.open.ac.uk/aikg/ontology#Metric",
    "http://scholkg.kmi.open.ac.uk/aikg/ontology#Task",
    "http://scholkg.kmi.open.ac.uk/aikg/ontology#OtherEntity",
    "http://www.w3.org/ns/org#Organization",
    "http://xmlns.com/foaf/0.1/Person",
    "http://xmlns.com/foaf/0.1/Project",
    "http://ontologies.metaphacts.com/competencies/Application",
    "http://ontologies.metaphacts.com/competencies/Functionality",
    "http://ontologies.metaphacts.com/competencies/Process"
  ],
  "readonly": false,
  "detectFields": false,
  "importGraph": false,
  "skipInitialIndexing": false,
  "boostProperties": [],
  "stripMarkup": false
}
''' .
}
```


### KMI Transformation
The KMI dataset has several shortcomings that we try to address with transforming SPARQL queries. To adapt the data, run the following queries:

#### Transform KMI ontology to SKOS Concept Scheme
Add skos:Concept statements:

```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    <http://scholkg.kmi.open.ac.uk/aikg/ontology> a skos:ConceptScheme .
    ?kmiClass a skos:Concept .
    
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    ?kmiClass a owl:Class .
}}
```

and add skos:broader statements:

```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    ?kmiSub skos:broader ?kmiSuper .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    ?kmiSub rdfs:subClassOf ?kmiSuper .
}}
```

#### Add SHACL shapes for domain and range constraints
```
PREFIX sh: <http://www.w3.org/ns/shacl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
 ?classShapeIri a sh:NodeShape ;
    sh:property [
      a sh:PropertyShape ;
      sh:path ?property ;
      sh:class ?range
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

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
  ?s ?p ?o .n
  <<?s ?p ?o>> ?stmt_pred ?stmt_obj .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
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

DELETE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
  ?stmt ?p ?o .
}}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
?stmt a kmi-ont:Statement;
  ?p ?o .
}}
```

#### Create labels for KMI
Classes:

```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    ?cls rdfs:label ?label .
  }
}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/ontology> {
    ?cls a owl:Class .
    BIND( STRAFTER(STR(?cls), "http://scholkg.kmi.open.ac.uk/aikg/ontology#") as ?label )
  }
}
```

Entities:

```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
    ?entity rdfs:label ?label .
  }
}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
    ?entity ?p ?o .
    FILTER ( STRSTARTS(STR(?entity), "http://scholkg.kmi.open.ac.uk/aikg/resource/") )
    BIND( REPLACE( STRAFTER(STR(?entity), "http://scholkg.kmi.open.ac.uk/aikg/resource/"), "_", " ", "i") as ?label )
  }
}
```

#### Create sameAs-links from KMI to MAKG
```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX kmi-ont: <http://scholkg.kmi.open.ac.uk/aikg/ontology#>

INSERT { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
    ?entity owl:sameAs ?makgEntity .
  }
}
WHERE { GRAPH <http://scholkg.kmi.open.ac.uk/aikg/resource> {
    ?entity a kmi-ont:MagPaper .
    BIND( IRI(CONCAT("https://makg.org/entity/", STRAFTER(STR(?entity), "http://scholkg.kmi.open.ac.uk/aikg/resource/"))) as ?makgEntity )
  }
}
```
