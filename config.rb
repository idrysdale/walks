require './app/app'

helpers do
  def generate_gallery(directory:, image_filenames:)
    r = "<div class='gallery'>"
    image_filenames.each do |image_filename|
      r += "<div class='image'>"
      r += "<a href='/images/photos/#{directory}/#{image_filename}.jpg' "
      ExcursionPage.photo_widths.each do |width|
        r += "data-at-#{width}='/images/photos/#{directory}/thumbs/#{image_filename}-#{width}.jpg' "
      end
      r += ">"
      r += "<img src='/images/photos/#{directory}/thumbs/#{image_filename}-#{ExcursionPage.photo_widths.min}.jpg' width='100%' />"
      r += "</a>"
      r += "</div>"
    end
    r += "</div>"
    return r
  end

  def hills_climbed_in_the_peaks
    factory = RGeo::Geos.factory
    peak_district_file = File.read('data/peak-district.json')
    peak_district_hash = JSON.parse(peak_district_file)

    points = peak_district_hash['geometry']['coordinates'][0].map { |p|
      factory.point(p[1], p[0])
    }

    peaks = factory.polygon(factory.line_string(points))

    ActivitiesHillsStore.new('peak-hills').get_hills_climbed_in(area: peaks, during: 2016)
  end

  def wainwrights_climbed_in_the_lakes
    factory = RGeo::Geos.factory
    lake_district_file = File.read('data/lake-district.json')
    lake_district_hash = JSON.parse(lake_district_file)

    points = lake_district_hash['geometry']['coordinates'][0].map { |p|
      factory.point(p[1], p[0])
    }

    lakes = factory.polygon(factory.line_string(points))

    ActivitiesHillsStore.new('peak-hills').get_hills_climbed_in(area: lakes, during: 2016)
  end

  def activities_up(hill_id)
    ActivitiesHillsStore.new('peak-hills').get_activities_that_climbed(hill_id)
  end

  def activities_for(excursion_id:)
    activity_store = ActivityStore.new('peak-hills')
    ExcursionStore.new('data/excursions.json', activity_store).get(excursion_id).activities
  end

  def friendly_list_of_activitities_dates_up(hill_id)
    activities_hill_store = ActivitiesHillsStore.new('peak-hills')
    activities = activities_hill_store.get_activities_that_climbed(hill_id)
    activities.map { |a|
      started_at = Date.parse(a.started_at)
      nice_started_at = started_at.strftime("%A %B #{started_at.day.ordinalize} '%y")
      "<a href='/activities/#{a.name.friendly_filename}.html'>#{nice_started_at}</a>"
    }.to_sentence
  end

  def last_updated
    ActivityStore.new('peak-hills').get_most_recent_activity_start_time
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end
