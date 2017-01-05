require "activity"
require "activity_data"
require "activity_hill_data"
require "activity_store"
require "activities_hills_store"
require "array"
require "course"
require "hill"
require "hill_data"
require "hill_store"
require "pg"
require 'postgres_parser'
require "pry"

RSpec.describe ActivitiesHillsStore do
  let(:test_database_name) { 'peak-hills-test' }
  subject(:activities_hills_store) { ActivitiesHillsStore.new(test_database_name) }
  let(:activity_store) { ActivityStore.new(test_database_name) }
  let(:hill_store) { HillStore.new(test_database_name) }
  let(:connection) { PG.connect(dbname: test_database_name) }
  let(:activity_data_today) {
    ActivityData.new(
      1,
      "A walk up t' hill",
      Time.now,
      [[1.1234,1.1234], [1.434,2.434]]
    )
  }
  let(:activity_data_2_days_ago) {
    ActivityData.new(
      2,
      "A run very fast",
      Time.now - (60*60*24* 2),
      [[3, 3], [2, 1]]
    )
  }
  let(:activity_data_8_days_ago) {
    ActivityData.new(
      3,
      "A slow stroll",
      Time.now - (60*60*24* 8),
      [[4, 3], [2, 1]]
    )
  }
  let(:activity_data_1_year_ago) {
    ActivityData.new(
      4,
      "An old stroll",
      Time.now - (60*60*24* 365),
      [[4, 3], [2, 1]]
    )
  }
  let(:activity_data_2_years_ago) {
    ActivityData.new(
      5,
      "An ancient stroll",
      Time.now - (60*60*24* 365 * 2),
      [[4, 3], [2, 1]]
    )
  }
  let(:kinder_scout_data) {
    HillData.new(
      "Kinder's Scout",
      [-1.874349, 53.384774],
      636,
      'SK084875'
    )
  }
  let(:bleaklow_data) {
    HillData.new(
      'Bleaklow',
      [-1.859062, 53.46116],
      633,
      'SK094960'
    )
  }
  let(:catsye_cam_data) {
    HillData.new(
      'Catstye Cam',
      [-3.00909, 54.53326],
      900,
      'NY348157'
    )
  }

  before do
    connection.exec("DELETE FROM activities_hills;")
    connection.exec("DELETE FROM activities;")
    connection.exec("DELETE FROM hills;")

    hill_store.push(kinder_scout_data)
    hill_store.push(bleaklow_data)
    hill_store.push(catsye_cam_data)

    @kinder_scout = hill_store.get(name: kinder_scout_data.name).first
    @bleaklow = hill_store.get(name: bleaklow_data.name).first
    @catsye_cam = hill_store.get(name: catsye_cam_data.name).first

    activity_store.push(activity_data_today)
    activity_store.push(activity_data_2_days_ago)
    activity_store.push(activity_data_8_days_ago)
    activity_store.push(activity_data_1_year_ago)
    activity_store.push(activity_data_2_years_ago)
  end

  describe 'pushing and getting hills climbed' do
    context 'with two activities, climbing two hills' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_2_days_ago.id,
            @catsye_cam.id
          )
        )
      end

      it 'globally, gets two records' do
        results = activities_hills_store.get_hills_climbed()
        expect(results.count).to eq(2)
      end

      it 'filters on an area, getting only the contained hills' do
        factory = RGeo::Geos.factory

        lake_district_file = File.read('spec/support/lake-district.json')
        lake_district_hash = JSON.parse(lake_district_file)

        points = lake_district_hash['geometry']['coordinates'][0].map { |p|
          factory.point(p[1], p[0])
        }

        lake_polygon = factory.polygon(factory.line_string(points))

        results = activities_hills_store.get_all_hills_climbed_in(area: lake_polygon)
        expect(results.count).to eq(1)
      end
    end

    context 'with one activity climbing two hills' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @bleaklow.id
          )
        )
        @results = activities_hills_store.get_hills_climbed()
      end

      it 'gets two records' do
        expect(@results.count).to eq(2)
      end
    end

    context 'with three activities climbing one hill' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_2_days_ago.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_8_days_ago.id,
            @kinder_scout.id
          )
        )
        @results = activities_hills_store.get_activities_that_climbed(@kinder_scout.id)
      end

      it 'gets three records' do
        expect(@results.count).to eq(3)
      end

      it 'gets the three activities, most recent first' do
        expect(@results.first.id).to eq(activity_data_today.id)
        expect(@results.last.id).to eq(activity_data_8_days_ago.id)
      end
    end
  end

  describe 'pushing and getting hills climbed' do
    context 'with two activities, climbing two hills' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_1_year_ago.id,
            @catsye_cam.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_1_year_ago.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_2_years_ago.id,
            @catsye_cam.id
          )
        )
      end

      it 'filters on year getting only the contained hills' do
        year = Time.now.year
        results = activities_hills_store.get_hills_climbed_during(year: year)
        expect(results.count).to eq(1)
        expect(results.first.name).to eq(@kinder_scout.name)

        one_year_ago = Time.now.year - 1
        results = activities_hills_store.get_hills_climbed_during(year: one_year_ago)
        expect(results.count).to eq(2)

        two_years_ago = Time.now.year - 2
        results = activities_hills_store.get_hills_climbed_during(year: two_years_ago)
        expect(results.count).to eq(1)
        expect(results.first.name).to eq(@catsye_cam.name)
      end
    end

    context 'with one activity climbing two hills' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @bleaklow.id
          )
        )
        @results = activities_hills_store.get_hills_climbed()
      end

      it 'gets two records' do
        expect(@results.count).to eq(2)
      end
    end

    context 'with three activities climbing one hill' do
      before do
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_2_days_ago.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_today.id,
            @kinder_scout.id
          )
        )
        activities_hills_store.push(
          ActivityHillData.new(
            activity_data_8_days_ago.id,
            @kinder_scout.id
          )
        )
        @results = activities_hills_store.get_activities_that_climbed(@kinder_scout.id)
      end

      it 'gets three records' do
        expect(@results.count).to eq(3)
      end

      it 'gets the three activities, most recent first' do
        expect(@results.first.id).to eq(activity_data_today.id)
        expect(@results.last.id).to eq(activity_data_8_days_ago.id)
      end
    end
  end

  after do
    connection.close
  end

end
