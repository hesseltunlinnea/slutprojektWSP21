module Model
    

    # Helper function for DRY, to avoid repition
    def database()
        db = SQLite3::Database.new('db/bilibil.db')
        db.results_as_hash = true
        return db
    end

    # Compares two inputs, in this case passwords
    #
    # @param [string] password1, first input
    # @param [string] password2, second input
    #
    # @return [Boolean] true if the passwords matches
    def password_comparison(password1, passoword2)
        if password1 == passoword2
            result = true
        else
            result = false
        end
        return result
    end

    # Checks the length of the password, should be over 6 symbols
    #
    # @param [string] password, chosen password
    #
    # @return [Boolean] true if password is long enough
    def password_length(password)
        if password.length < 6
            result = false
        else
            result = true
        end
    end

    # Checks if username is taken/exists, helper function DRY
    #
    # @param [string] username, inputed username
    #
    # @return [Boolean] true if username is available (not takes)
    def username_checker(username)
        db = database()
        return db.execute('SELECT id FROM Users where username = ?', username) == []
    end
        
    # Registers user, uses help functions
    #
    # @param [string] first_name, first name of user
    # @param [string] last_name, last name of user
    # @param [string] username, chosen username
    # @param [string] tel, telephone number
    # @param [string] email, email of user
    # @param [string] password, chosen password
    # @param [string] confirmation_password, repeated password
    #
    # @see Model#password_comparison
    # @see Model#password_length
    #
    # @return [Boolean]  
    def register_user(first_name, last_name, username, tel, email, password, confirmation_password)
        register_accepted = false
        if password_comparison(password, confirmation_password) == false
            register_accepted = false
            error = "Lösenorden stämmer inte överns"
        elsif password_length(password) == false
            register_accepted = false
            error = "Lösenordet måste vara minst 6 tecken"
        elsif username_checker(username) == false
            register_accepted = false
            error = "Användarnamnet är upptaget"
        else
            password_digest = BCrypt::Password.create(password)
            db = database()
            db.execute('INSERT INTO Users (first_name, last_name, username, phone_number, email, password_digest) values (?,?,?,?,?,?)', first_name, last_name, username, tel, email, password_digest)
            register_accepted = true
            error = nil
        end

        register_result = [register_accepted, error]

        return register_result
    
    end


    # Lets users log in
    #
    # @param [string] username,  username of user
    # @param [string] password,  password of user
    #
    # @return [Array] first boolean wheter login iis accepted and then user_id
    def login_user(username, password)
        db = database()
        #nedasntående if-sats fungerar ej
        if username_checker(username) == true
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

    # Lets users add vehicles
    #
    # @param [Integer] avatar, key of chosen avatar image
    # @param [string] license_number, license number of vehicle
    # @param [Integer] user_id, id of user
    def add_vehicle(avatar, license_number, user_id)
        db = database()
        db.execute('INSERT INTO Cars (avatar, license_number) values (?,?)', avatar, license_number)
        car_information = db.execute('SELECT id FROM Cars WHERE license_number = ?', license_number)
        car_id = car_information.first['id']
        db.execute('INSERT INTO CarUser (user_id, car_id) values (?,?)', user_id, car_id )
    end

    #Help function to user_Car_information, checks if user owns any cars
    #
    # @param [Integer] user_id, id of user
    #
    # @return [Boolean] true if user owns car
    def user_car_checker(user_id)
        db = database()
        if db.execute('SELECT * from CarUser WHERE user_id = ?', user_id) == []
            return false
        else
            return true
        end
    end

    # Collects data about the user's cars
    #
    # @param [Integer] user_id, id of user
    #
    # @return [Hash]
    #   * :id [integer] id of car
    #   * :avatar [Integer] id of avatar image
    #   * :license_number [String] license number of car
    # @return [Boolean] false if user has no car
    def user_car_information(user_id)
        db = database()
        if user_car_checker(user_id) == true
            car_information_of_user = db.execute('SELECT * FROM (Cars INNER JOIN CarUser ON Cars.id = CarUser.car_id) WHERE user_id=?', user_id )
        #än så länge gör jag bara informationen för första bilen men jag vill att man ska kunna välja
            return car_information_of_user
        else
            return false
        end
    end

    # Checks if chosen car has got bookings
    #
    # @param [Integer] car_id, id of car
    #
    # @return [Boolean] false if chosen car has no bookings
    def car_booked_checker(car_id)
        db = database()
        if db.execute('SELECT * from Booking WHERE car_id = ?', car_id) == []
            return false
        else
            return true
        end
    end

    # Collects last booking data of chosen car
    #
    # @param [Integer] car_id, id of car
    #
     # @return [Array] 
    #   * booking_made [String] when booking was made
    #   * datetime_booked [String] time booked
    def car_booking_information(car_id)
        db = database()
        last_booking = db.execute('SELECT booking_made, datetime_booked FROM Booking').last
        booking_made = last_booking['booking_made'] #.strftime("%Y-%m-%d %H:%M")
        datetime_booked = last_booking['datetime_booked'].to_s 
        last_booking_array = [booking_made, datetime_booked]
        return last_booking_array
    end

    # Saves booking of car
    #
    # @param [Integer] user_id, id of user
    # @param [Integer] car_id, id of car
    # @param [String] datetime_booked, time booked
    # @param [Integer] booking_made, time when booked
    #
    def save_booking(user_id, car_id, datetime_booked, booking_made)
        db = database()
        db.execute('INSERT INTO Booking (user_id, car_id, booking_made, datetime_booked) VALUES (?,?,?,?)', user_id, car_id, booking_made, datetime_booked)
    end

    # Checks if user is admin
    #
    # @param [Integer] user_id, id of user
    #
    # @return [Boolean] true if user is admin
    def admin_checker(user_id)
        db = database()
        db.results_as_hash = false
        admin_array = db.execute('SELECT user_id FROM AdminUsers')
        if admin_array.include?([user_id])
            return true
        else
            return false
        end
    end

    # Collects number if users and number of bookings from database
    #
    # @return [Array]
    #  * numbers of users [Integer] number of registered users
    #  * number of bookings [Integer] total number of bookings
    def statistics_retriever()
        db = database()
        db.results_as_hash = false
        last_user_id = db.execute('SELECT id FROM Users').last
        number_of_users = last_user_id[0] + 1
        last_booking_id = db.execute('SELECT id from Booking').last
        number_of_bookings = last_booking_id[0] + 1
        statistics_array = [number_of_users, number_of_bookings]
        return statistics_array
    end

    # Collects data of bookings of specific car
    #
    # @param [Integer] car_id, id of car in question
    ""
    # @return [Array] 
    #   * booking_made [String] when booking was made
    #   * datetime_booked [String] time booked
    #   * id [Integer] id of the booking
    #   * user_id [Integer] id of user who made the booking
    def booking_retriever(car_id)
        db = database()
        db.results_as_hash = false
        bookings = db.execute('SELECT booking_made, datetime_booked, id, user_id FROM Booking WHERE car_id=? ORDER BY datetime_booked', car_id )
        return bookings
    end 

    # Deletes booking
    #
    # @param [Integer] id, id of booking to be deleted
    # @param [Integer] user_id, id of the user logged in and who made the booking
    def delete_booking(id, user_id)
        db = database()
        db.execute('DELETE FROM booking WHERE id =?', id)
    end

    # Update booking
    #
    # @param [Integer] id, id of booking to be updated
    # @param [Integer] user_id, id of the user logged in and who made the booking
    def update_booking(id, user_id, booking_made, datetime_booked)
        db = database()
        db.execute('UPDATE booking SET booking_made=?, datetime_booked=? WHERE id=?', booking_made, datetime_booked, id)
    end

    # Deletes user from database, on cascade delete
    #
    # @param [Integer] id, id of user to be deleted
    def delete_account(id)
        db = database()
        db.execute('DELETE FROM Users WHERE id = ?', id)
        db.execute('DELETE FROM Booking WHERE user_id = ?', id)
        db.execute('DELETE FROM CarUser WHERE user_id = ?', id)
        db.execute('DELETE FROM AdminUsers WHERE user_id = ?', id)
    end
end

