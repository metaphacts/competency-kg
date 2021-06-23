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

1. Make sure that you are running metaphactory with docker-compose (default setup) and use BlazeGraph as data store - otherwise the data import will not work as expected.

2. Make sure that BlazeGraph has enough RAM to process the file upload. The easiest way to do that is adding the following lines to the `services` section of the `docker-compose.overwrite.yml` in your deployment:
```
blazegraph:
    environment:
       - JAVA_OPTS=-Xmx4g
```
Hint: Restart your metaphactory instance (if it is running) to load the updated configuration.

3. First check that your metaphactory instance is running, then execute `/bin/sh run_import.sh <deployment-name>` where `<deployment-name>` should be replaced with the name of your metaphactory deployment. The import may take several minutes.

### KMI Ontology Visualisation
The KMI ontology is represented using domain statements based on RDF lists. This notation can not be visualised with metaphactory and Ontodia. Further, the ontology is not using skos-ontology. To adapt the ontology, run the following personal queries (which are delivered with the app):
* `kmi-skos-concept` (adds the skos:Concept type to all classes in KMI)
* `kmi-skos-broader` (creates skos:broader relationships between parent and child concepts)
* `kmi-dereification` (creates plain triples from all the reified statements)
* `kmi-owlunion-to-shaclshape-conversion` (generates SHACL shapes for representation of domain and range values)