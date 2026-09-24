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
    puts "Performed SPARQL transformation from #{sparql_path}"
  end
  return graph
end

# --- Index (listing) based discovery -----------------------------------------
# robots.txt only exposes an English sitemap with no French events, so instead
# we crawl the language-specific event listing pages and derive counterparts.

EVENT_PATH_REGEX = %r{https?://nac-cna\.ca/(en|fr)/event/[^"'#?\s]+}

# Listing pages per language. Pagination is followed via ?page=N until a page
# yields no new event links (or the max page cap is reached).
INDEX_PAGES = [
  "https://nac-cna.ca/en/discover",
  "https://nac-cna.ca/fr/discover"
]

def scrape_index_page(url)
  html = Nokogiri::HTML(URI.open(url))
  links = html.css('a[href]').map { |a| a['href'] }
  # Normalize relative hrefs to absolute
  links.map! do |href|
    href.start_with?('http') ? href : "https://nac-cna.ca#{href}"
  end
  links.grep(EVENT_PATH_REGEX)
rescue StandardError => e
  puts "Error scraping index #{url}: #{e.message}"
  []
end

def collect_event_urls(index_pages, max_pages: 50)
  found = []
  index_pages.each do |base|
    (1..max_pages).each do |page|
      page_url = page == 1 ? base : "#{base}?page=#{page}"
      puts "Checking index page #{page_url}"
      urls = scrape_index_page(page_url)
      new_urls = urls - found
      break if new_urls.empty?
      found.concat(new_urls)
    end
  end
  found.uniq
end

def derive_counterpart_urls(urls)
  urls.flat_map do |u|
    [u, u.sub('/en/event/', '/fr/event/').sub('/fr/event/', '/en/event/')]
  end
end

# Build the full en/fr event list.
entity_urls = collect_event_urls(INDEX_PAGES)

# Ensure both language versions exist for every discovered event id.
entity_urls = entity_urls
  .flat_map { |u| [u.sub('/fr/event/', '/en/event/'), u.sub('/en/event/', '/fr/event/')] }
  .uniq

puts "entity_urls (#{entity_urls.size}): #{entity_urls}"

sparql_file = File.read('./src/sparql/add_derived_from.sparql')
entity_urls.each do |entity_url|
  begin
    entity_url = entity_url.gsub(' ', '+')
    loaded_graph = RDF::Graph.load(entity_url)
    sparql_file_with_url = sparql_file.gsub("subject_url", entity_url)
    loaded_graph.query(SPARQL.parse(sparql_file_with_url, update: true))
    graph << loaded_graph
  rescue StandardError => e
    puts "Error loading RDF from #{entity_url}: #{e.message}"
    # break
  end
end

sparql_paths = [
  "./src/sparql/make-uris.sparql",
  "./src/sparql/set-organizer.sparql",
  "./src/sparql/remove_empty_organizations.sparql",
]
graph = perform_sparql_transformations(graph, sparql_paths)

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end

puts "Saved JSON-LD to file #{file_name}"
