

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
    
    login_accepted = nil

    if BCrypt::Password.new(password_digest) == password   
        login_accepted = true
    else
        login_accepted = false
    end

    login_result_array = [login_accepted, user_id]

    return login_result_array

end

def add_vehicle(avatar, license_number, user_id)
    db = database()
    db.execute('INSERT INTO Cars (avatar, license_number) values (?,?)', avatar, license_number)
    car_id = db.execute('SELECT id FROM Cars WHERE license_number = ?', license_number)
    db.execute('INSERT INTO CarUser (user_id, car_id) values (?,?)', user_id, car_id )
end


def user_car_information(user_id)
    db = database()
    cars_of_user = db.execute('SELECT car_id from CarUser WHERE user_id=?', user_id )
    #än så länge gör jag bara informationen för första bilen men jag vill att man ska kunna välja
    cars_information = db.execute('SELECT * FROM Cars WHERE id = ?', cars_of_user[0])
    license_number = cars_information['license_number']
    avatar = cars_information['avatar']

    return cars_information

end