require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions


get('/')do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password1]
    login_user(username, password)
    if login_accepted = true
        session[:user_id] = user_id
        redirect('home')
    else
        p "fel!!"
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
    password1 = params[:password1]
    password2 = params[:password2]

    if register_user(first_name, last_name, username, tel, email, password1, password2) == true
        redirect('login')
    else
        #felmeddelande
    end

end