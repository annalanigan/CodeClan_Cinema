require('../db/sql_runner')

class Film

  attr_reader :id, :title, :price

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @price = options['price']
  end

end
