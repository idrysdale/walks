require 'rgeo'
require 'rgeo-geojson'

class Hill
  attr_reader :id, :name, :coordinates, :absolute_height,
    :grid_ref, :url

  def initialize(
    id, name, coordinates, absolute_height,
    grid_ref, url = nil
  )
    @id = id
    @name = name
    @coordinates = coordinates
    @absolute_height = absolute_height
    @grid_ref = grid_ref
    @url = url
  end

  def summit
    factory.point(coordinates[1], coordinates[0]).buffer(0.002)
  end

  def factory
    RGeo::Geos.factory
  end

  def local_url
    "/hills/#{self.name.friendly_filename}.html"
  end
end
