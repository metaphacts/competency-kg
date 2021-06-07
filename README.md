# Competency Knowledge Graph

The Competency Knowledge Graph is an effort to represent the broad field of artificial intelligence in a single knowledge graph. The idea is to describe the technical perspective (methods, tasks, models, metrics, ..) as well as the business perspective (use cases, sectors, business units, ..) in order to bridge the gap between theory and practice. Potential use cases of this graph may be the identification of relevant use cases for a given task, or the discovery of methods to solve a certain problem.

## Getting Started
### App Deployment
To deploy the app, include the folder `competency-kg-app` as volume in the `/apps` directory (if using docker). Alternatively, you can upload a zipped version of the folder `competency-kg-app` via Admin:Apps in your metaphactory instance.

### Data
The app currently uses two data sources:
- The Computer Science Ontology which you have to download from [here](https://cso.kmi.open.ac.uk/downloads) and import into metaphactory
- The KMI ScholKG ontology which is referenced via an external SPARQL endpoint (as it is too large to conveniently load into metaphactory)
