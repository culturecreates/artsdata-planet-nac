require 'minitest/autorun'
require 'linkeddata'

class ReplaceBlankNodesTest < Minitest::Test

  def setup
    @remove_empty_organizations_sparql_file = "./src/sparql/remove_empty_organizations.sparql"
  end

  # check that the blank node is replaced
  def test_blank_node_replaced
    sparql = SPARQL.parse(File.read(@remove_empty_organizations_sparql_file), update: true)
    graph = RDF::Graph.load("./tests/fixtures/remove_empty_organizations.jsonld")
    # puts "before: #{graph.dump(:jsonld)}"
    graph.query(sparql)
    # puts "after: #{graph.dump(:jsonld)}"
    assert_equal 1, graph.query([RDF::URI("https://nac-cna.ca/en/event/has_organization"), RDF::URI("http://schema.org/organizer"), nil]).count
    assert_equal 0, graph.query([RDF::URI("https://nac-cna.ca/en/event/no_organization"), RDF::URI("http://schema.org/organizer"), nil]).count
  end
end
