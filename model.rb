
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
    #nedasntående if-sats fungerar ej
    if db.execute('SELECT id FROM Users where username = ?', username) == nil
        login_accepted = false
        login_result_array = [login_accepted]
        return login_result_array
    end

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
    car_information = db.execute('SELECT id FROM Cars WHERE license_number = ?', license_number)
    car_id = car_information.first['id']
    db.execute('INSERT INTO CarUser (user_id, car_id) values (?,?)', user_id, car_id )
end


def user_car_information(user_id)
    db = database()
    car_information_of_user = db.execute('SELECT * FROM (Cars INNER JOIN CarUser ON Cars.id = CarUser.car_id) WHERE user_id=?', user_id ).first
    #än så länge gör jag bara informationen för första bilen men jag vill att man ska kunna välja

    license_number = car_information_of_user['license_number']
    avatar = car_information_of_user['avatar']
    

    return car_information_of_user

end

def save_booking()
    db = database()
    db.execute('INSERT INTO Booking (user_id, car_id, booking_made, datetime_booked) VALUES (?,?,?,?)', session[:user_id], session[:car_id], booking_made, datetime_booked)

end