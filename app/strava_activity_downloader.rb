require 'logger'
require 'strava/api/v3'

class StravaActivityDownloader

  def initialize(client, activity_store)
    @logger = Logger.new("log.log")
    @logger.level = Logger::INFO

    @activity_store = activity_store
    @client = client
  end

  def download_activities(started_since:)
    data_of_new_activities(started_since).each do |activity_data|
      @activity_store.push(activity_data)
    end
  end

  private

  def unix_epoch_time(iso8601_time)
    iso8601_time.nil? ? nil : Time.parse(iso8601_time).to_i
  end

  def data_of_new_activities(started_since)
    concat_arrays(
      Enumerator.new { |yielder|
        loop do
          activities = download_new_activities(started_since)
          yielder.yield(activities)
          break if activities.empty?

          started_since = activities.last.started_at
        end
      }
    )
  end

  def concat_arrays(array_of_arrays)
    array_of_arrays.reduce(:+)
  end

  def download_new_activities(started_since)
    params = {
      'after' => unix_epoch_time(started_since),
      'per_page' => 100
    }
    @client.list_athlete_activities(params)
      .select { |strava_activity|
        course_data = download_course_data_for(strava_activity['id'])
        course_data != nil
      }
      .map { |strava_activity|
        # sleep(2)
        course_data = download_course_data_for(strava_activity['id'])
        ActivityData.new(
          strava_activity['id'],
          strava_activity['name'].tr("'", ""),
          strava_activity['start_date'],
          course_data
        )
      }
    rescue SocketError
      puts "We got a Net::HTTP SocketError!!!"
      return []
  end

  def download_course_data_for(activity_id)
    begin
      activity_stream = @client.retrieve_activity_streams(activity_id, 'latlng').first
      return activity_stream['data']
    rescue Strava::Api::V3::ClientError
      @logger.warn("Couldn't find course for activity #{activity_id}")
      return nil
    end
  end
end
