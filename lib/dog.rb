class Dog
  attr_accessor :name, :breed, :id

def initialize(hash)
  @name = hash[:name]
  @breed = hash[:breed]
  @id = nil 
end

def self.create_table
sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
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
        INSERT INTO dogs(name,breed) VALUES (?, ?);
        SQL
  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def self.create(hash)
  dog = Dog.new(hash)
  dog.save
  dog
end

def self.find_by_id(num)
  sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?;
        SQL
  dog = DB[:conn].execute(sql, num)[0]
  new_dog = self.new_from_db(dog)
end

def self.new_from_db(row)
  hash = {id: row[0], name: row[1], breed: row[2]}
  dog = Dog.new(hash)
  dog.id = hash[:id]
  dog
end

def self.find_or_create_by(hash)

dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
#new_dog = {id: old_dog[0], name: old_dog[1], breed: old_dog[2]}
if(dog.empty?)
  dog = self.create(hash)
else 
  new_dog = dog[0]
  dog = self.new_from_db(new_dog)
end
dog
end

def self.find_by_name(name)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
  self.new_from_db(dog)
end

def update 
  sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end
end