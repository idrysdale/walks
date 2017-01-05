class ActivityData
  attr_reader :id, :name, :started_at, :course_data

  def initialize(id, name, started_at, course_data)
    @id = id
    @name = name
    @started_at = started_at
    @course_data = course_data
  end
end
