class Activity
  attr_reader :id, :name, :started_at, :course

  def initialize(id, name, started_at, course)
    @id = id
    @name = name
    @started_at = started_at
    @course = course
  end
end
