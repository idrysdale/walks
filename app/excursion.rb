class Excursion
  attr_reader :id, :name, :activities

  def initialize(id, name, activities)
    @id = id
    @name = name
    @activities = activities
  end
end
