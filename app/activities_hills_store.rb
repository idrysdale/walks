require 'pg'

class ActivitiesHillsStore
  def initialize(database_name)
    @connection = PG.connect(dbname: database_name)
  end

  def push(activity_hill_data)
    @connection.exec("INSERT INTO activities_hills
      (
        activity_id,
        hill_id
      )
      VALUES
      (
        '#{activity_hill_data.activity_id}',
        '#{activity_hill_data.hill_id}'
      )
    ")
  end

  def get_hills_climbed()
    @connection.exec("SELECT DISTINCT hills.*
      FROM hills
      INNER JOIN activities_hills
      ON hills.id = activities_hills.hill_id;
    ").map do |hill_row|
      summit_array = PostgresParser.new.parse_pg_array(hill_row['coordinates']).map { |c|
        c.to_f
      }
      Hill.new(
        hill_row['id'],
        hill_row['name'],
        summit_array,
        hill_row['absolute_height'],
        hill_row['grid_ref'],
        hill_row['url']
      )
    end
  end

  def get_all_hills_climbed_in(area:)
    get_hills_climbed().select { |hill|
      area.contains?(hill.summit)
    }
  end

  def get_hills_climbed_during(year:)
    @connection.exec("SELECT DISTINCT hills.*
      FROM activities
      INNER JOIN activities_hills
        ON activities.id = activities_hills.activity_id
      INNER JOIN hills
        on activities_hills.hill_id = hills.id
      WHERE
        activities.started_at >= '#{year}-01-01 00:00:00'
        AND activities.started_at <= '#{year + 1}-01-01 00:00:00'
      ;").map do |hill_row|
      summit_array = PostgresParser.new.parse_pg_array(hill_row['coordinates']).map { |c|
        c.to_f
      }
      Hill.new(
        hill_row['id'],
        hill_row['name'],
        summit_array,
        hill_row['absolute_height'],
        hill_row['grid_ref'],
        hill_row['url']
      )
    end
  end

  def get_hills_climbed_in(area:, during:)
    get_hills_climbed_during(year: during).select { |hill|
      area.contains?(hill.summit)
    }
  end

  def get_activities_that_climbed(hill_id)
    @connection.exec("SELECT DISTINCT activities.*
      FROM activities
      INNER JOIN activities_hills
      ON activities.id = activities_hills.activity_id
      WHERE activities_hills.hill_id = #{hill_id}
      ORDER BY activities.started_at DESC;
    ").map do |activity_row|
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

  def get_activities()
    @connection.exec("SELECT DISTINCT activities.*
      FROM activities
      INNER JOIN activities_hills
      ON activities.id = activities_hills.activity_id;
    ").map do |activity_row|
      course_array = PostgresParser.new.
        parse_pg_array(activity_row['course']).map { |c|
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
end
