class HillPage

  def initialize(file_directory)
    @file_directory = file_directory
    FileUtils.mkdir_p "#{@file_directory}/"
  end

  def generate(hill)
    file_name = "#{@file_directory}/#{hill.name.friendly_filename}.html.haml"
    File.open(file_name, "w") do |f|
      f.puts '---'
      f.puts 'layout: hill'
      f.puts "name: #{hill.name}"
      f.puts "hill_id: #{hill.id}"
      f.puts "summit: #{hill.coordinates}"
      f.puts '---'
    end
  end

end
