require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions


get('/home')do
    cars_information = user_car_information(session[:user_id])
    if cars_information != []
        session[:license_number] = cars_information['license_number']
        session[:avatar] = cars_information['avatar']
        session[:car_id] = cars_information['id']
        slim(:home, locals:{license_number:session[:license_number], avatar:session[:avatar]})
    else
        avatar = 1
        slim(:home, locals:{avatar:avatar, license_number:"Lägg till bil"})
    end
end

get('/user/login') do
    slim(:'user/login', locals:{error:""})
end

get('/user/login/error') do
    slim(:'user/login', locals:{error:"Fel användarnamn eller lösenord"})
end

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

get('/user/register') do
    slim(:'user/register')
end

post('/register') do
    first_name = params[:first_name]
    last_name = params[:last_name]
    username = params[:username]
    tel = params[:phone_number]
    email = params[:email]
    password1 = params[:password1]
    password2 = params[:password2]

    if register_user(first_name, last_name, username, tel, email, password1, password2) == true
        redirect('/login')
    else
        #felmeddelande
        redirect('/user/regiser')
    end

end

get('/add_vehicle') do
    slim(:add_vehicle)
end

post('/add_vehicle') do
    avatar = params[:avatar]
    license_number = params[:license_number]
    add_vehicle(avatar, license_number, session[:user_id])
    redirect('home')
end

get('/book') do
    slim(:book)
end

post('/book') do
    datetime_booked = params[:datetime_booked]
    booking_made = params[:booking_made]

    db = database()
    db.execute('INSERT INTO Booking (user_id, car_id, booking_made, datetime_booked) VALUES (?,?,?,?)', session[:user_id], session[:car_id], booking_made, datetime_booked)

    redirect('/home')
end

get('/user/settings') do
    slim(:'user/settings')
end

