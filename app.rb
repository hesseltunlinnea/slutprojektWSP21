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
    slim(:'user/register', locals:{error:""})
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
        redirect('/user/login')
    else
        redirect('/user/register/error')
    end

end

get('/user/register/error') do
    slim(:'user/register', locals:{error:"Lösenordet måste vara minst 6 tecken långt och ska skrivas två gånger"})
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
    slim(:'booking/book')
end

post('/book') do
    datetime_booked = params[:datetime_booked]
    booking_made = params[:booking_made]

    save_booking( session[:user_id], session[:car_id], datetime_booked, booking_made)
    
    redirect('/home')
end

get('/user/settings') do
    cars_information = user_car_information(session[:user_id])
    slim(:'user/settings', locals:{cars:cars_information})
end

before('/admin/statistics') do
    if admin_checker(session[:user_id]) == false
        redirect('/home')
    end
end

get('/admin/statistics') do
    statistics = statistics_retriever()
    slim(:'admin/statistics_overview', locals:{number_of_users:statistics[0], number_of_bookings:statistics[1]})
  
end

get('/bookings') do
    bookings = booking_retriever(session[:car_id])
    slim(:'booking/read_bookings', locals:{bookings:bookings})
end

post('/bookings/:id/delete') do
    delete_booking(params[:id], session[:user_id])
    redirect('/bookings')
end