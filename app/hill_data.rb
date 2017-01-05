class HillData
  attr_reader :name, :coordinates, :absolute_height,
    :grid_ref, :url

  def initialize(
    name, coordinates, absolute_height,
    grid_ref, url = nil
  )
    @name = name
    @coordinates = coordinates
    @absolute_height = absolute_height
    @grid_ref = grid_ref
    @url = url
  end
end
