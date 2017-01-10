class ActivityPage

  def initialize(file_directory, activity)
    @file_directory = file_directory
    @activity = activity
    FileUtils.mkdir_p "#{@file_directory}/"
  end

  def generate()
    file_name = "#{@file_directory}/#{@activity.name.friendly_filename}.html.haml"
    File.open(file_name, "w") do |f|
      f.puts '---'
      f.puts 'layout: activity'
      f.puts "name: #{@activity.name}"
      f.puts "activity_id: #{@activity.id}"
      f.puts "started_at: #{@activity.started_at}"
      f.puts '---'
    end
  end

end
