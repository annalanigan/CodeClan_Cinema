require_relative('../db/sql_runner')

class Screening

  attr_reader :id, :film_id, :start_time
  attr_accessor :empty_seats

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @film_id = options['film_id']
    @start_time = options['start_time']
    @empty_seats = options['empty_seats'].to_i
  end

  def save
    sql = "INSERT INTO screenings (
          	film_id,
          	start_time,
            empty_seats
          )
          VALUES ( $1,$2,$3 )
          RETURNING id;"
    values = [@film_id, @start_time, @empty_seats]
    result = SqlRunner.run(sql, values).first
    @id = result['id'].to_i
  end

  def update
    sql = ('UPDATE screenings
          SET (film_id, start_time, empty_seats) = ($1, $2, $3)
          WHERE id = $4')
    values = [@film_id, @start_time, @empty_seats, @id]
    return SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = 'DELETE FROM screenings'
    SqlRunner.run(sql)
  end

  def self.all
    sql = 'SELECT * FROM screenings'
    screenings = SqlRunner.run(sql)
    return self.map_items(screenings)
  end

  def self.map_items(screenings_data)
    return screenings_data.map { |screening| Screening.new(screening) }
  end

  def self.find(id)
    sql = "SELECT * FROM screenings WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values).first
    return Screening.new(result)
  end

  

  # def fully_booked
  #   @empty_seats = 0
  # end

  def fill_seat
    @empty_seats -= 1
    update
  end

end
