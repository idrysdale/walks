require 'strava_activity_downloader'
require 'activity'
require 'activity_data'
require 'activity_store'
require 'pg'
require 'postgres_parser'
require 'course'

require 'support/strava_api_v3_client_double'

RSpec.describe StravaActivityDownloader do
  let(:test_database_name) { 'peak-hills-test' }
  let(:connection) { PG.connect(dbname: test_database_name) }
  let(:client) { StravaApiV3ClientDouble.new }
  let(:activity_store) { ActivityStore.new(test_database_name) }

  subject(:strava_activity_downloader) {
    StravaActivityDownloader.new(client, activity_store)
  }

  before do
    connection.exec("DELETE FROM Activities")
  end

  describe '#download_activities' do
    context 'with activities to download' do
      before do
        strava_activity_downloader
          .download_activities(started_since: '2016-10-08T06:25:07Z')
      end

      it 'gets the data and pushes to the store' do
        expect(activity_store.get_all.count).to eq 4
      end
    end

    context 'with an empty course (probably a manual entry)' do
      before do
        strava_activity_downloader
          .download_activities(started_since: '2016-10-07T06:25:07Z')
      end

      it 'gets the data and pushes to the store' do
        expect(activity_store.get_all.count).to eq 4
      end
    end
  end

  after do
    connection.close
  end
end
