require 'array'
require 'silva'
require 'hill'
require 'hill_data'
require 'hill_store'
require 'wikipedia_hill_scraper'
require 'pg'
require 'postgres_parser'
require 'nokogiri'

RSpec.describe WikipediaHillScraper do
  let(:domain) { 'spec/support' }
  let(:path) { '/hills_in_peaks.html' }

  let(:test_database_name) { 'peak-hills-test' }
  let(:hill_store) { HillStore.new(test_database_name) }
  let(:connection) { PG.connect(dbname: test_database_name) }

  subject(:wikipedia_hill_scraper) {
    WikipediaHillScraper.new(domain, path, hill_store)
  }

  before do
    connection.exec("DELETE FROM hills")
  end

  describe "#scrape_hills" do
    before do
      wikipedia_hill_scraper
        .scrape_hills()
    end

    it "gets the hills and pushes them to the store" do
      expect(hill_store.get_all.count).to eq 2
    end
  end

  after do
    connection.close
  end
end
