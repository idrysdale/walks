require 'bundler/setup'
Bundler.require(:default)

require 'json'
require 'logger'
require 'open-uri'
require 'yaml'

namespace :wikipedia do
  desc "Get the hills from Wikipedia"
  task :scrape do
    require './app/app'
    domain = "https://en.wikipedia.org"
    path = "/wiki/List_of_hills_in_the_Peak_District"
    hill_store = HillStore.new('peak-hills')

    WikipediaHillScraper.new(domain, path, hill_store).scrape_hills
  end
end

namespace :json do
  desc "Get the wainwrights into the database from json"
  task :push_wainwrights do
    require './app/app'
    hill_store = HillStore.new('peak-hills')

    file = File.read('data/wainwrights.json')
    data_hash = JSON.parse(file)

    hills = data_hash.map { |dh|
      name = dh['properties']['name']
      coordinates = dh['geometry']['coordinates']
      absolute_height = dh['properties']['absolute_height']
      grid_ref = Silva::Location.from(:wgs84, lat: coordinates[1], long: coordinates[0]).to(:gridref, digits: 6).to_s
      link = dh['properties']['link']

      HillData.new(
        name,
        coordinates,
        absolute_height,
        grid_ref,
        false,
        link,
        'wainwright'
      )
    }

    hills.each { |hill|
      puts "Storing #{hill.name}"
      hill_store.push(hill)
    }
  end
end

namespace :site do
  desc 'Generate the hill HTML files'
  task :generate_hill_html_files do
    require './app/app'
    activities_hills_store = ActivitiesHillsStore.new('peak-hills')

    activities_hills_store.get_hills_climbed.each do |hill|
      HillPage.new('source/hills').generate(hill)
    end
  end

  desc 'Generate the peak district activity JSON files and accompanyting HTML'
  task :generate_activity_pages do
    require './app/app'
    activities_hills_store = ActivitiesHillsStore.new('peak-hills')

    activities_hills_store.get_activities.each do |activity|

      activity_json = {
        type: 'FeatureCollection',
        features: [
          {
            type: 'Feature',
            properties: {
              name: activity.name,
              link: "http://strava.com/activities/#{activity.id}",
            },
            geometry: {
              type: 'LineString',
              coordinates: activity.course.route.coordinates.map { |p| [p[1], p[0]] }
            }
          }
        ]
      }

      FileUtils.mkdir_p "source/activities"
      File.open("source/activities/#{activity.id}.json","w") do |f|
        f.write(JSON.pretty_generate(activity_json))
      end

      ActivityPage.new('source/activities').generate(activity)
    end
  end

  desc 'Generate the excursion HTML files'
  task :generate_excursion_html_files do
    require './app/app'
    activity_store = ActivityStore.new('peak-hills')
    excursion_store = ExcursionStore.new('data/excursions.json', activity_store)

    excursion_store.get_all.each do |excursion|
      ExcursionPage.new('source/excursions').generate(excursion)
    end
  end

  task :generate_excursion_activity_json_files do
    require './app/app'
    activity_store = ActivityStore.new('peak-hills')
    excursion_store = ExcursionStore.new('data/excursions.json', activity_store)

    excursion_store.get_all.each do |excursion|
      features_collection = {
        type: 'FeatureCollection',
        features: []
      }
      excursion.activities.each do |activity|
        feature = {
          type: 'Feature',
          properties: {
            name: activity.name,
            link: "http://strava.com/activities/#{activity.id}",
          },
          geometry: {
            type: 'LineString',
            coordinates: activity.course.route.coordinates.map { |p| [p[1], p[0]] }
          }
        }
        features_collection[:features] << feature
      end

      FileUtils.mkdir_p "source/excursions"

      File.open("source/excursions/#{excursion.name.friendly_filename}.json","w") do |f|
        f.write(JSON.pretty_generate(features_collection))
      end
    end

    FileUtils.mkdir_p "source/excursions/simplified"

    Dir.chdir(File.join(File.dirname(__FILE__), 'source', 'excursions'))
    Dir.glob('*.json').each do |filename|
      basename = File.basename(filename, '.json')
      `ogr2ogr -f GeoJSON simplified/#{basename}.json #{basename}.json -simplify 0.0001`
    end

  end
end

namespace :strava do
  desc "Get the activities off Strava into the database"
  task :download_activities do
    require './app/app'
    client = Strava::Api::V3::Client.new(access_token: ENV["PEAK_HILLS_STRAVA_KEY"])
    activity_store = ActivityStore.new('peak-hills')
    time = activity_store.get_most_recent_activity_start_time

    StravaActivityDownloader.new(client, activity_store).download_activities(started_since: time)
  end
end

namespace :geo do
  desc "Find which strava activities intersect the hills"
  task :calculate_intersections do
    require './app/app'
    factory = RGeo::Geos.factory
    activity_store = ActivityStore.new('peak-hills')
    hill_store = HillStore.new('peak-hills')
    activities_hills_store = ActivitiesHillsStore.new('peak-hills')

    peak_district_file = File.read('data/peak-district.json')
    peak_district_hash = JSON.parse(peak_district_file)

    points = peak_district_hash['geometry']['coordinates'][0].map { |p|
      factory.point(p[1], p[0])
    }

    peak_polygon = factory.polygon(factory.line_string(points))

    lake_district_file = File.read('data/lake-district.json')
    lake_district_hash = JSON.parse(lake_district_file)

    points = lake_district_hash['geometry']['coordinates'][0].map { |p|
      factory.point(p[1], p[0])
    }

    lake_polygon = factory.polygon(factory.line_string(points))

    hills = hill_store.get_all

    activity_store.get_all.each do |activity|
      puts "🔎 Checking activity #{activity.id}"
      if peak_polygon.contains?(activity.course.route) ||
         peak_polygon.intersects?(activity.course.route) ||
         lake_polygon.contains?(activity.course.route) ||
         lake_polygon.intersects?(activity.course.route)
        puts "✅ Activity is in the Peaks / Lakes"
        hills.each do |hill|
          if activity.course.route.intersects?(hill.summit)
            puts "✅ Climbed #{hill.name}"
            activities_hills_store.push(ActivityHillData.new(activity.id, hill.id))
          end
        end
      end
    end
  end
end
