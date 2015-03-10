# on osx install virtuoso via brew

# run virtuoso in the foreground
cd /usr/local/Cellar/virtuoso/7.1.0/var/lib/virtuoso/db
virtuoso-t -f


# select all triples as variables 
# s (subject), p (predicate), o (object)
select * where {
	?s ?p ?o
} limit 100

select ?person where {
	?person a <http://xmlns.com/foaf/0.1/Person>
} limit 100

# running federated queries requires additional permissions
# set permissions via isql
# just type isql on the prompt and run the following commands
grant select on "DB.DBA.SPARQL_SINV_2" to "SPARQL";
grant execute on "DB.DBA.SPARQL_SINV_IMP" to "SPARQL";
grant execute on "DB.DBA.SPARUL_LOAD_SERVICE_DATA" to "SPARQL";
grant execute on "DB.DBA.SPARQL_SD_PROBE" to "SPARQL";
grant execute on "DB.DBA.L_O_LOOK" to "SPARQL";


# Running a simple federated query on DBpedia SPARQL endpoint
SELECT DISTINCT ?person WHERE {
	SERVICE <http://dbpedia.org/sparql> 
		{ ?person a <http://xmlns.com/foaf/0.1/Person> . }
} LIMIT 30


# Instead of having only their URIs, let us try to get
# more readable data. Lets simplify the query 
# by prefixing the foaf ontology.
# let us target actors instead of just persons
# let us filter actors named Angelina and see if 
# Angelina Jolie is one of the results
PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
PREFIX umbel:   <http://umbel.org/umbel/rc/>
SELECT DISTINCT ?person ?name WHERE {
	SERVICE <http://dbpedia.org/sparql> 
		{ ?person a         foaf:Person ;
							foaf:name ?name ;
							a         umbel:Actor .
			FILTER regex(?name, "Angelina")
		}
} LIMIT 30


# Running a federated query gathering movies starring 
# Brad Pitt on Linked Movie Database and collecting 
# his birth date on DBpedia
PREFIX imdb:    <http://data.linkedmdb.org/resource/movie/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX dbpo:    <http://dbpedia.org/ontology/>
PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
PREFIX rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
PREFIX umbel:   <http://umbel.org/umbel/rc/>

SELECT DISTINCT ?personName ?birthDate ?movieTitle ?movieDate WHERE {
  { SERVICE <http://data.linkedmdb.org/sparql>
    { ?person1 a               imdb:actor .
      ?person1 imdb:actor_name "Brad Pitt" .
      ?person1 imdb:actor_name ?personName .
      ?movie   imdb:actor      ?person1 ;
               dcterms:title   ?movieTitle ;
               dcterms:date    ?movieDate 
    }
  }
  { SERVICE <http://dbpedia.org/sparql>
    { ?person2 a               umbel:Actor ;
               owl:sameAs      <http://data.linkedmdb.org/resource/producer/9826> ;
               dbpo:birthDate  ?birthDate
    }
  }
} ORDER BY ?movieDate LIMIT 40

