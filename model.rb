def database()
    db = SQLite3::Database.new('db/bilibil.db')
    db.results_as_hash = true
    return db
end

def password_comparison(password1, passoword2)
    if password1 == passoword2
        result = true
    else
        result = false
    end
    return result
end

def password_length(password)
    if password.length < 6
        result = false
    else
        result = true
    end
end
    

def register_user(first_name, last_name, username, tel, email, password, confirmation_password)
    if password_comparison(password, confirmation_password) == false
        register_accepted = false
        #skicka felmeddelande


    elsif password_length(password) == false
        register_accepted = false
        #skicka felmeddelande
    else
        password_digest = BCrypt::Password.create(password)
        db = database()
        db.execute('INSERT INTO Users (first_name, last_name, username, phone_number, email, password_digest) values (?,?,?,?,?,?)', first_name, last_name, username, tel, email, password_digest)
        register_accepted = true
    return true
end
end

def login_user(username, password)
    db = database()
    user_info_db = db.execute('SELECT id, password_digest FROM Users WHERE username = ?', username)
    user_id = user_info_db.first['id']
    password_digest = user_info_db.first['password_digest']

    if BCrypt::Password.new(password_digest) == entered_password      
        login_accepted = true
    else
        login_accepted = false
    end

    return login_accepted, user_id

end