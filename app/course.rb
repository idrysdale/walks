require 'rgeo'
require 'rgeo-geojson'

class Course
  attr_reader :geo_points

  def initialize(coordinates_list)
    @geo_points = coordinates_list&.map { |coordinate|
      factory.point(coordinate[0], coordinate[1])
    }
  end

  def route
    factory.line_string(@geo_points)
  end

  def factory
    RGeo::Geos.factory
  end
end
