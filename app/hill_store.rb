require 'pg'

class HillStore
  def initialize(database_name)
    @connection = PG.connect(dbname: database_name)
  end

  def push(hill_data)
    begin
      @connection.prepare('insert_hill', 'INSERT into hills(
        name,
        coordinates,
        absolute_height,
        grid_ref,
        url
      ) values ($1, $2, $3, $4, $5)')
    rescue PG::DuplicatePstatement
    end
    @connection.exec_prepared('insert_hill',[
      hill_data.name,
      hill_data.coordinates.to_sql,
      hill_data.absolute_height,
      hill_data.grid_ref,
      hill_data.url
    ])
  end

  def get_all
    @connection.exec("SELECT * FROM hills").map do |hill_row|
      instantiate_hill_from_hill_row(hill_row)
    end
  end

  def get(id:)
    @connection.exec("SELECT * FROM hills WHERE id = #{id}").map do |hill_row|
      instantiate_hill_from_hill_row(hill_row)
    end
  end

  def get(name:)
    begin
      @connection.prepare('select_hill_by_name',
        'SELECT * FROM hills where name = $1')
    rescue PG::DuplicatePstatement
    end
    @connection.exec_prepared('select_hill_by_name', [name]).map do |hill_row|
      instantiate_hill_from_hill_row(hill_row)
    end
  end

  private

  def summit_array(coordinates)
    PostgresParser.new.parse_pg_array(coordinates).map { |coordinate|
        coordinate.to_f
    }
  end

  def instantiate_hill_from_hill_row(hill_row)
    Hill.new(
      hill_row['id'],
      hill_row['name'],
      summit_array(hill_row['coordinates']),
      hill_row['absolute_height'],
      hill_row['grid_ref'],
      hill_row['url']
    )
  end
end
