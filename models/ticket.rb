require_relative('../db/sql_runner')

class Ticket

  attr_reader :id, :customer_id, :screening_id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @customer_id = options['customer_id'].to_i
    @screening_id = options['screening_id'].to_i
  end

  def save
    sql = 'INSERT INTO tickets (
          	customer_id,
          	screening_id
          )
          VALUES ( $1,$2 )
          RETURNING id;'
    values = [@customer_id, @screening_id]
    result = SqlRunner.run(sql, values).first
    @id = result['id'].to_i
  end

  def self.delete_all
    sql = "DELETE FROM tickets"
    SqlRunner.run(sql)
  end

  def self.all
    sql = "SELECT * FROM tickets"
    tickets =  SqlRunner.run(sql)
    return self.map_items(tickets)
  end

  def self.map_items(ticket_data)
    return ticket_data.map { |ticket| Ticket.new(ticket) }
  end

end
