class ExcursionStore
  def initialize(excursions_file, activity_store)
    @excursions_file = excursions_file
    @activity_store = activity_store
  end

  def get_all
    file = File.read(@excursions_file)
    data = JSON.parse(file)
    data.map { |row|
      Excursion.new(
        row['id'],
        row['name'],
        row['activities'].map { |activity_id|
          @activity_store.get(activity_id)
        }
      )
    }
  end
end
