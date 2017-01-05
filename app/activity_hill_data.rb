class ActivityHillData
  attr_reader :activity_id, :hill_id

  def initialize(activity_id, hill_id)
    @activity_id = activity_id
    @hill_id = hill_id
  end
end
