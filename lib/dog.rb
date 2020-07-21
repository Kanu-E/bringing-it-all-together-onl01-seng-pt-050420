
class Dog
  attr_accessor :id, :name, :breed

  def initialize (id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def  self.create_table
     sql = <<-SQL
       CREATE TABLE dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       grade TEXT)
       SQL
     DB[:conn].execute(sql)
  end

  def self.drop_table
  sql = <<-SQL
  DROP TABLE dogs 
          SQL
     DB[:conn].execute(sql)    
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) 
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
       
       row_hash = {id: row[0],
       name: row[1],
       breed: row[2]}
       dog = self.new(row_hash)
    end

    def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
       SQL
 
    DB[:conn].execute(sql, id).collect {|row|self.new_from_db(row)}.first
    end

    def  self.find_or_create_by(name:, breed:)

     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

     if dog.empty?
      dog = self.create(name: name, breed: breed)
     else
      dog_values = dog[0]
      dog = Dog.new_from_db(dog_values)
     end
     dog
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL
   
      DB[:conn].execute(sql, name).collect {|row|self.new_from_db(row)}.first
      end
    
      def update
        sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

end