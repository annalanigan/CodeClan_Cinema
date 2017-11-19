require_relative('../db/sql_runner')

class Customer

  attr_reader :id
  attr_accessor :funds, :name

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @funds = options['funds'].to_i
  end

  def save
    sql = "INSERT INTO customers (
          	name,
          	funds
          )
          VALUES ( $1,$2 )
          RETURNING id;"
    values = [@name, @funds]
    result = SqlRunner.run(sql, values).first
    @id = result['id'].to_i
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end

  def self.all
    sql = 'SELECT * FROM customers'
    customers = SqlRunner.run(sql)
    return self.map_items(customers)
  end

  def self.map_items(customers)
    return customers.map { |customer| Customer.new(customer) }
  end

  def self.find(id)
    sql = "SELECT * FROM customers WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values).first
    return Customer.new(result)
  end

  def update
    sql = ('UPDATE customers
          SET (name, funds) = ($1, $2)
          WHERE id = $3')
    values = [@name, @funds, @id]
    return SqlRunner.run(sql, values)
  end

  def film
    sql = ('SELECT * from films
          INNER JOIN screenings
          ON screenings.film_id = films.id
          INNER JOIN tickets
          ON tickets.screening_id = screenings.id
          INNER JOIN customers
          ON customers.id = tickets.customer_id
          WHERE customers.id = $1')
    values = [@id]
    result = SqlRunner.run(sql, values)
    result.map { |item| Film.new(item)}
  end

  def pay_for_ticket(value)
    @funds -= value
    update
  end

  def buy_ticket(screening)
    if screening.empty_seats > 0
      sql = ('SELECT price FROM films
      INNER JOIN screenings
      ON screenings.film_id = films.id
      WHERE screenings.id = $1')
      values = [screening.id]
      result = SqlRunner.run(sql,values)[0]['price'].to_i
      if result <= @funds
        pay_for_ticket(result)
        new_ticket = Ticket.new({'customer_id' => @id, 'screening_id' => screening.id})
        new_ticket.save
        screening.fill_seat
      else
        p 'not enough funds to purchase ticket'
      end
    else
      p 'fully booked'
    end
  end

end
