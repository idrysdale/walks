class Excursion
  attr_reader :id, :name, :activities, :photo_filenames

  def initialize(id, name, activities, photo_filenames = nil)
    @id = id
    @name = name
    @activities = activities
    @photo_filenames = photo_filenames
  end
end
