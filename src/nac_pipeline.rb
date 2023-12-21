#!/usr/bin/env ruby

require_relative './utils/artsdata'

graph = 'http://nac-cna.ca/nac-events'
pipeline = ArtsdataPipeline.new

pipeline.load(file: '../dump/nac-get_rdf.jsonld')


pipeline.transform("./sparql/fix-start-dates.sparql")
pipeline.transform("./sparql/fix-end-dates.sparql")
pipeline.transform("./sparql/make-uris.sparql")
pipeline.transform("./sparql/set-organizer.sparql")
pipeline.transform("./sparql/fix-places.sparql")

pipeline.dump("../output/transformed-#{graph.split("/").last}.json")


puts "Framing..."
pipeline.frame( "../frame/events.jsonld")

puts "Saving JSON-LD..."
pipeline.dump("../output/#{graph.split("/").last}.json")

puts "Validating shapes... #{graph.split("/").last}"
pipeline.validate("https://raw.githubusercontent.com/culturecreates/artsdata-data-model/master/shacl/shacl_artsdata.ttl")
pipeline.report("../output/#{graph.split("/").last}.yml")