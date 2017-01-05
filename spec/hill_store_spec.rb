require 'array'
require 'hill'
require 'hill_data'
require 'hill_store'
require 'pg'
require 'postgres_parser'
require 'pry'

RSpec.describe HillStore do
  let(:test_database_name) { 'peak-hills-test' }
  subject(:hill_store) { HillStore.new(test_database_name) }
  let(:connection) { PG.connect(dbname: test_database_name) }

  let(:factory) { RGeo::Geos.factory }

  before do
    connection.exec("DELETE FROM activities_hills")
    connection.exec("DELETE FROM hills")
  end

  describe '#push' do
    let(:new_hill_data) {
      HillData.new(
        "Kinder's Scout",
        [-1.874349, 53.384774],
        636,
        'SK084875',
        'https://en.wikipedia.org/wiki/Kinder_Scout'
      )
    }

    before do
      hill_store.push(new_hill_data)
      @results = hill_store.get_all
    end

    it 'inserts a row in the database' do
      expect(@results.count).to be 1
    end

    it 'returns a Hill' do
      expect(@results.first).to be_a(Hill)
    end

    it 'writes the name as expected' do
      expect(@results.first.name).to eq(new_hill_data.name)
    end

    it 'writes the summit as expected' do
      expect(@results.first.summit).to eq(
        factory.point(
          new_hill_data.coordinates[1],
          new_hill_data.coordinates[0]
        ).buffer(0.002)
      )
    end
  end

  describe '#get_all' do
    context 'with no hills' do
      it { expect(hill_store.get_all).to eq [] }
    end

    context 'with two hills' do
      let(:hill_one_data) {
        HillData.new(
          'Bleaklow',
          [-1.859062, 53.46116],
          633,
          'SK094960'
        )
      }
      let(:hill_two_data) {
        HillData.new(
          'Kinder Scout',
          [-1.874349, 53.384774],
          636,
          'SK084875'
        )
      }

      before do
        hill_store.push(hill_one_data)
        hill_store.push(hill_two_data)
      end

      it 'has 2 items' do
        expect(hill_store.get_all.size).to be 2
      end

      it 'returns hills' do
        retrieved_hill_one = hill_store.get_all.first

        expect(retrieved_hill_one).to be_a Hill
        expect(retrieved_hill_one.name).to eq(hill_one_data.name)
        expect(retrieved_hill_one.coordinates).to eq(hill_one_data.coordinates)
      end
    end
  end

  after do
    connection.close
  end
end
