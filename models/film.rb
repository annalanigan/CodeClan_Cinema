 ('../db/sql_runner')

class Film

  attr_reader :id
  attr_accessor :title, :price

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @price = options['price'].to_i
  end

  def save
    sql = 'INSERT INTO films (
          	title,
          	price
          )
          VALUES ( $1,$2 )
          RETURNING id'
    values = [@title, @price]
    film = SqlRunner.run(sql, values).first
    @id = film['id'].to_i
  end

  def self.delete_all
    sql = "DELETE FROM films"
    SqlRunner.run(sql)
  end

  def self.all
    sql = 'SELECT * FROM films'
    films = SqlRunner.run(sql)
    return self.map_items(films)
  end

  def self.map_items(films_data)
    return films_data.map { |film| Film.new(film) }
  end

  def self.find(id)
    sql = "SELECT * FROM films WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values).first
    return Film.new(result)
  end

  def update
    sql = 'UPDATE films
            SET (title, price) = ($1, $2)
            WHERE id = $3'
    values = [@title, @price, @id]
    return SqlRunner.run(sql, values)
  end

  def customer
    sql = ('SELECT * from customers
          INNER JOIN tickets
          ON tickets.customer_id = customers.id
          INNER JOIN films
          ON films.id = tickets.film_id
          WHERE films.id = $1')
    values = [@id]
    result = SqlRunner.run(sql, values)
    result.map { |item| Customer.new(item)}
  end

end
