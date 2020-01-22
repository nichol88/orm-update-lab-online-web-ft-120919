require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def save

    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (? , ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.create(name, grade)
    s = self.new(name, grade)
    s.save
  end

  def self.new_from_db(row)
    s = self.new
    s.id = row[0]
    s.name = row[1]
    s.grade = row[2]
    s
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map{ |row| self.new_from_db(row)}.first
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
