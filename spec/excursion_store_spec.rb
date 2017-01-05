require "array"
require "activity_store"
require "activity"
require "activity_data"
require "course"
require "excursion"
require "excursion_store"
require "pg"
require "postgres_parser"
require "pry"
require "rb-readline"

RSpec.describe ExcursionStore do
  let(:day) { 60 * 60 * 24 }

  let(:test_database_name) { 'peak-hills-test' }
  let(:activity_store) { ActivityStore.new(test_database_name) }
  let(:connection) { PG.connect(dbname: test_database_name) }
  let(:activity_one_data) {
    ActivityData.new(
      1,
      "A walk up t' hill",
      Time.now - (1 * day),
      [[1.1234,1.1234], [1.434,2.434]]
    )
  }
  let(:activity_two_data) {
    ActivityData.new(
      2,
      "A walk down t' hill",
      Time.now - (2 * day),
      [[1.434,2.434], [1.1234,1.1234]]
    )
  }
  let(:activity_three_data) {
    ActivityData.new(
      3,
      "A walk up a completely different hill",
      Time.now - (14 * day),
      [[1,4], [1,5]]
    )
  }

  subject(:excursion_store) {
    ExcursionStore.new(
      "spec/support/two_excursions.json",
      activity_store
    )
  }

  before do
    connection.exec("DELETE FROM activities_hills")
    connection.exec("DELETE FROM activities")

    activity_store.push(activity_one_data)
    activity_store.push(activity_two_data)
    activity_store.push(activity_three_data)
  end

  describe 'getting excursions' do
    before do
      @results = excursion_store.get_all
    end

    it 'retrieves the right number of excursions from the file' do
      expect(@results.count).to be 2
    end

    it 'returns an array of Excursions' do
      expect(@results.first).to be_an(Excursion)
    end

    it 'returns the correct number of activities for an excursion' do
      expect(@results.first.activities.count).to be 2
    end

    it 'returns an array of activities for each excursion' do
      expect(@results.first.activities.first).to be_an(Activity)
    end

    it 'returns an array of activities for each excursion' do
      expect(@results.first.activities.first.name).to eq(activity_one_data.name)
    end
  end

  after do
    connection.close
  end
end
