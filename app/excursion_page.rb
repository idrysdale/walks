class ExcursionPage

  def initialize(file_directory)
    @file_directory = file_directory
    FileUtils.mkdir_p "#{@file_directory}/"
  end

  def generate(excursion)
    file_name = "#{@file_directory}/#{excursion.name.friendly_filename}.html.haml"
    File.open(file_name, "w") do |f|
      f.puts '---'
      f.puts 'layout: excursion'
      f.puts "name: #{excursion.name}"
      f.puts "excursion_id: #{excursion.id}"
      f.puts '---'
    end
  end

end
