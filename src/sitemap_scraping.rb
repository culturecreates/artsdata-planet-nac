require 'nokogiri'
require 'open-uri'
require 'linkeddata'

if ARGV.length != 2
  puts "Usage: ruby script_name.rb <sitemap_url>  <file_name>"
  exit
end

sitemap_url = ARGV[0]
file_name = ARGV[1]

graph = RDF::Graph.new

def perform_sparql_transformations(graph, sparql_paths)
  sparql_paths.each do |sparql_path|
    graph.query(SPARQL.parse(File.read(sparql_path), update: true))
  end
  return graph
end

sitemap_xml = Nokogiri::XML(URI.open(sitemap_url))
# Extract URLs that start with 'https://nac-cna.ca/en/event/'
ns = { 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' }
entity_urls = sitemap_xml.xpath('//xmlns:url[starts-with(xmlns:loc, "https://nac-cna.ca/en/event/")]/xmlns:loc', ns).map(&:text)
entity_urls.each do |entity_url|
  begin
    entity_url = entity_url.gsub(' ', '+')
    graph << RDF::Graph.load(entity_url)
  rescue StandardError => e
    puts "Error loading RDF from #{entity_url}: #{e.message}"
    break
  end
end

sparql_paths = [
  "./src/sparql/fix-date.sparql",
  "./src/sparql/fix-start-dates.sparql",
  "./src/sparql/fix-end-dates.sparql",
  "./src/sparql/fix-event-status.sparql",
  "./src/sparql/fix-places.sparql",
  "./src/sparql/make-uris.sparql",
  "./src/sparql/remove-blank-descriptions.sparql",
  "./src/sparql/set-organizer.sparql"
]
graph = perform_sparql_transformations(graph, sparql_paths)

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end
