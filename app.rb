require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

helpers do

    def database()
        db = SQLite3::Database.new('db/bilibil.db')
        db.results_as_hash = true
        return db
    end

end

get('/')do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password1]
    db = database()
    user_info_db = db.execute('SELECT id, password_digest FROM Users WHERE username = ?', username)
    user_id = user_info_db.first['id']
    password_digest = user_info_db.first['password_digest']

    if BCrypt::Password.new(password_digest) == entered_password
        session[:user_id] = user_id
        redirect('/home')
    else
        redirect()
        #Till en felsida eller liknande
    end

end

get('/register') do
    slim(:register)
end

post('/register') do
    first_name = params[:first_name]
    last_name = params[:last_name]
    username = params[:username]
    tel = params[:phone_number]
    email = params[:email]
    entered_password = params[:password1]
    password_digest = BCrypt::Password.create(entered_password)
    db = databse()
    db.execute('INSER INTO Users (first_name, last_name, username, phone_number, email, password_digest) values (?,?,?,?,?,?)', first_name, last_name, username, tel, email, password_digest)
    redirect('login')

end