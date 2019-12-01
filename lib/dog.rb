class Dog
    
    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def self.create(name:, breed:)
        new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
    end

    def self.find_by_id(id)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        found = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)[0]
        found ? new_from_db(found) : create(name: name, breed: breed)
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", @name, @breed, @id)
    end

    def save
        if @id
            update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
            self
        end
    end

end