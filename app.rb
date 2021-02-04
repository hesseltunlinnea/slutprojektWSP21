require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

helpers do

    def database
        db = SQLite3::Database.new('db/bilibil.db')
        db.results_as_hash = true
        return db
    end

end

get('/')do
    slim(:login)
end

post('/login') do

end