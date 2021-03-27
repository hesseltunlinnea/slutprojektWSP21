require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions


get('/home')do
    cars_information = user_car_information(session[:user_id])
    if cars_information != []
        license_number = cars_information['license_number']
        avatar = cars_information['avatar']
        slim(:home, locals:{license_number:license_number, avatar:avatar})
    else
        avatar = 1
        slim(:home, locals:{avatar:avatar})
    end
end

get('/user/login') do
    slim(:'user/login')
end

post('/login') do
    username = params[:username]
    password = params[:password]
    login_result_array = login_user(username, password)
    if login_result_array[0] == false
        redirect('/user/login')
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

get('/user/settings') do
    slim(:'user/settings')
end

