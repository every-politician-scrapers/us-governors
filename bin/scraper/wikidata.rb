#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT DISTINCT (STRAFTER(STR(?stateItem), STR(wd:)) AS ?stateid) ?state
     (STRAFTER(STR(?governor), STR(wd:)) AS ?item)
     ?name ?enLabel ?gender ?dob ?dobPrecision ?source
     (STRAFTER(STR(?ps), '/statement/') AS ?psid)
  WHERE {
    ?stateItem wdt:P31/wdt:P279* wd:Q852446 ; wdt:P1313 ?position .
    ?position wdt:P279* wd:Q132050 .
    ?governor p:P39 ?ps .
    ?ps ps:P39 ?position ; pq:P580 ?start .
    FILTER NOT EXISTS { ?ps pq:P582 [] }

    OPTIONAL {
      ?ps prov:wasDerivedFrom ?ref .
      ?ref pr:P854 ?source .
      FILTER CONTAINS(STR(?source), 'nga.org') .
      OPTIONAL { ?ref pr:P1810 ?sourceName }
    }
    OPTIONAL { ?governor rdfs:label ?enLabel FILTER(LANG(?enLabel) = "en") }
    BIND(COALESCE(?sourceName, ?enLabel) AS ?name)

    OPTIONAL { ?governor wdt:P21 ?genderItem }
    OPTIONAL {
      ?governor p:P569/psv:P569 [wikibase:timeValue ?dob ; wikibase:timePrecision ?dobPrecision]
    }

    SERVICE wikibase:label {
      bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en".
      ?genderItem rdfs:label ?gender .
      ?stateItem rdfs:label ?state .
    }
  }
  ORDER BY STR(?state)
SPARQL

agent = 'every-politican-scrapers/us-governors'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
