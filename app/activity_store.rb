require 'pg'

class ActivityStore
  def initialize(database_name)
    @connection = PG.connect(dbname: database_name)
  end

  def push(activity_data)
    begin
      @connection.prepare('insert_activity', 'INSERT into activities(
        id,
        name,
        started_at,
        course
      ) values ($1, $2, $3, $4)')
    rescue PG::DuplicatePstatement
    end
    @connection.exec_prepared('insert_activity',[
      activity_data.id,
      activity_data.name,
      activity_data.started_at,
      activity_data.course_data.to_sql
    ])
  end

  def activity_exists_for?(id)
    result = @connection.exec("SELECT * FROM activities where ID = #{id}")
    result.count == 1
  end

  def get_all
    @connection.exec("SELECT * FROM activities ORDER BY started_at DESC").map do |activity_row|
      course_array = PostgresParser.new.parse_pg_array(activity_row['course']).map { |c|
        c.map { |s| s.to_f }
      }
      Activity.new(
        activity_row['id'].to_i,
        activity_row['name'],
        activity_row['started_at'],
        Course.new(course_array)
      )
    end
  end

  def get(id)
    activity_row = @connection.exec("SELECT * FROM activities WHERE id = #{id} LIMIT 1").first
    course_array = PostgresParser.new.parse_pg_array(activity_row['course']).map { |c|
      c.map { |s| s.to_f }
    }
    Activity.new(
      activity_row['id'].to_i,
      activity_row['name'],
      activity_row['started_at'],
      Course.new(course_array)
    )
  end

  def get_most_recent_activity_start_time
    activity_row = @connection.exec("SELECT started_at FROM activities ORDER BY started_at DESC limit 1").first
    if activity_row.nil?
      return nil
    else
      activity_row['started_at']
    end
  end
end
