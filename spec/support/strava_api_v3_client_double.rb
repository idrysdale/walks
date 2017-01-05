class StravaApiV3ClientDouble
  require 'pry'

  def list_athlete_activities(params)
    case params['after']
    when 1475907907
      file_name = "four_complete_activities_with_courses"
    when 1476165166
      file_name = "empty_array"
    when 1475821507
      file_name = "one_empty_course"
    end

    file = File.read(
      "spec/support/#{file_name}.json"
    )
    data = JSON.parse(file)
  end

  def retrieve_activity_streams(activity_id, type)
    file = File.read(
      "spec/support/retrieve_activity_streams_#{activity_id}_latlng.json"
    )
    data = JSON.parse(file)
  end

end
