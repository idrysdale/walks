class ExcursionPage

  def self.photo_widths
    [475, 800, 1366, 1920]
  end

  def initialize(file_directory, excursion)
    @file_directory = file_directory
    @excursion = excursion
    FileUtils.mkdir_p "#{@file_directory}/"
  end

  def generate()
    file_name = "#{@file_directory}/#{@excursion.name.friendly_filename}.html.haml"
    File.open(file_name, "w") do |f|
      f.puts '---'
      if has_photos?
        f.puts 'layout: excursion-gallery'
      else
        f.puts 'layout: excursion'
      end
      f.puts "name: #{@excursion.name}"
      f.puts "excursion_id: #{@excursion.id}"
      f.puts "photo_filenames: #{@excursion.photo_filenames}" if has_photos?
      f.puts '---'
    end
  end

  private

  def has_photos?()
    !@excursion.photo_filenames.nil?
  end

end
