require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions
include Model

before() do
    if (session[:user_id] ==  nil) && (request.path_info != '/user/login') && (request.path_info != '/user/register')
        session[:error] = "You need to log in to see this"
        redirect('/user/login')
    end 
    session[:admin_authority] = admin_checker(session[:user_id])
end

# Display login page
#
get('/user/login') do
    slim(:'user/login', locals:{error:""})
end

# Display login page with username or password error
#
get('/user/login/error') do
    slim(:'user/login', locals:{error:"Fel användarnamn eller lösenord"})
end

# Attempts login and updates the session, redirects to either '/user/login/error' or '/home'
# 
# @param [String] username, The username
# @param [String] password, The inputed password
#
# @see Model#login_user
post('/user/login') do
    username = params[:username]
    password = params[:password]
    login_result_array = login_user(username, password)
    if login_result_array[0] == false
        redirect('/user/login/error')
    else
        session[:user_id] = login_result_array[1]
        redirect('/home')
    end

end

# Displays register page with register form
#
get('/user/register') do
    slim(:'user/register', locals:{error:""})
end

# Creates a new user and redirects to "/user/login" or '/user/register/error'  
# 
# @param [String] username, chosen username of the user
# @param [String] first_name, first name of user
# @param [String] last name , last of the user
# @param [Integer] phone_number, phone number of user
# @param [String] email, email of user
# @param [String] password1, The inputed password of the user
# @param [String] password2, The second inputed password of the user for confirmation
#
# @see Model#register_user
post('/register') do
    first_name = params[:first_name]
    last_name = params[:last_name]
    username = params[:username]
    tel = params[:phone_number]
    email = params[:email]
    password1 = params[:password1]
    password2 = params[:password2]

    if register_user(first_name, last_name, username, tel, email, password1, password2) == true
        redirect('/user/login')
    else
        redirect('/user/register/error')
    end

end

# Displays register error if the two passwords do not match or password is shorter than 6 symbols
#
get('/user/register/error') do
    slim(:'user/register', locals:{error:"Lösenordet måste vara minst 6 tecken långt och ska skrivas två gånger"})
end

# Displays home page and the car of the users and information of bookings
#
# @param [Integer] user_id, the session of the user saved when logging in
#
# @see Model#user_car_information
# @see Model#car_booked_checker
# @see Model#car_booking_information
# @see Model#booking_retriever
get('/home')do
    cars_information = user_car_information(session[:user_id]).first
    
    if cars_information != false
        session[:license_number] = cars_information['license_number']
        session[:avatar] = cars_information['avatar']
        session[:car_id] = cars_information['id']

        if car_booked_checker(session[:car_id]) == true
            last_booking_array = car_booking_information(session[:car_id])
            upcoming_booking = booking_retriever(session[:car_id]).first[1].split('T')
            datetime_booked = last_booking_array[1].split("T")
            slim(:home, locals:{license_number:session[:license_number], avatar:session[:avatar], booking_made:last_booking_array[0], datetime_booked:"#{datetime_booked[0]} #{datetime_booked[1]}", upcoming_booking:"#{upcoming_booking[0]} #{upcoming_booking[1]}"})
        else
            slim(:home, locals:{license_number:session[:license_number], avatar:session[:avatar], booking_made:"Ingen information att hämta", datetime_booked:"Ingen information att hämta", upcoming_booking:"Ingen information att hämta"})
        end
    else
        avatar = 1
        slim(:home, locals:{avatar:avatar, license_number:"Lägg till bil", booking_made:"Ingen information att hämta", datetime_booked:"Ingen information att hämta", upcoming_booking:"Ingen information att hämta"})
    end

   
end

# Displays form to add vehicle
#
get('/add_vehicle') do
    slim(:add_vehicle)
end

# Lets user add vehicle and redirects to '/home'
# 
# @param [Integer] avatar, key to avatar image of car
# @param [String] license_number, license number of new car
#
# @see Model#add_vehicle
post('/add_vehicle') do
    avatar = params[:avatar]
    license_number = params[:license_number]
    add_vehicle(avatar, license_number, session[:user_id])
    redirect('home')
end

# Displays booking form
#
get('/book') do
    slim(:'booking/book')
end

# Allows user to book a time to use car, redirects to '/home'
# 
# @param [String] datetime_booked, chosen date and time for booking
# @param [String] booking_made, time when booking was made
#
# @see Model#save_booking
post('/book') do
    datetime_booked = params[:datetime_booked]
    booking_made = params[:booking_made]

    save_booking( session[:user_id], session[:car_id], datetime_booked, booking_made)
    
    redirect('/home')
end

# Displays settings and car of user
# 
# @param [Integer] user_id, the session of the user saved when logging in
#
# @see Model#user_car_information
get('/user/settings') do
    cars_information = user_car_information(session[:user_id])
    slim(:'user/settings', locals:{cars:cars_information})
end

# Checks if user is admin before directing to '/admin/statistics'
#
# @param [Integer] user_id, the session of the user saved when logging in
#
# @see Model#admin_checker
before('/admin/statistics') do
    if admin_checker(session[:user_id]) == false
        redirect('/home')
    end
end

# Displays statistics, only accessible to admins
#
# @see Model#statistics_retriever
get('/admin/statistics') do
    statistics = statistics_retriever()
    slim(:'admin/statistics_overview', locals:{number_of_users:statistics[0], number_of_bookings:statistics[1]})
  
end

# Displays booking of specific car
#
# @param [Integer] car_id, the session of the car
#
# @see Model#booking_retriever
get('/bookings') do
    bookings = booking_retriever(session[:car_id])
    slim(:'booking/read_bookings', locals:{bookings:bookings})
end

# Deletes bookings, can only delete bookings made by current user, redirects to '/bookings'
#
# @param [Integer] id, id of the booking that user wishes to delete
# @param [Integer] car_id, the session of the car
#
# @see Model#delete_booking
post('/bookings/:id/delete') do
    delete_booking(params[:id], session[:user_id])
    redirect('/bookings')
end