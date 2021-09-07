class Dog
    attr_accessor :id, :name, :breed
    
    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-YURR
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        YURR
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-YURR
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        YURR
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        self
    end

    def self.create(data)
        dog = Dog.new(data)
        dog.save
        dog
    end

    def self.new_from_db(doggy)
        dog = self.new(id: doggy[0], name: doggy[1], breed: doggy[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-YURR
            SELECT * FROM dogs WHERE id = ? LIMIT 1
        YURR
        dog = DB[:conn].execute(sql, id)[0]
        new_dog = Dog.new_from_db(dog)
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}'").map do |row|
            dog = self.new_from_db(row)
        end.first
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = '#{self.name}', breed = '#{self.breed}' WHERE id = '#{self.id}'")
    end

end
