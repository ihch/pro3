require 'sinatra'
require 'sinatra/reloader'
require 'mongo'

DB_NAME = "App"
USER_COL_NAME = "User"
CLIENT = Mongo::Client.new(["127.0.0.1:27017"], :database => "App")
DATABASE = CLIENT.database
USER_COL = CLIENT[USER_COL_NAME]

configure do
  enable :sessions
end

get '/' do
  redirect to('/index')
end

get '/index' do
  if session[:username] then
    "Hello World<br>#{session[:username]}'s page"
  elsif
    redirect to('/login')
  end
end

get '/login' do
  erb :login
  # "you must login"
end

get '/logout' do
  session.clear
  redirect to('/index')
end

post '/login' do
  username = params[:username]
  password = params[:password]

  for i in USER_COL.find() do
    puts i
  end

  session[:username] = username
  session[:password] = password

  "#{username}: #{password}"
end

get '/register' do
  erb :register, :isFailed => false
end

post '/register' do
  username = params[:username]
  password = params[:password]

  if USER_COL.find({name: username}).count != 0
    return erb(:register, :isFailed => true)
  end

  session[:username] = username
  session[:password] = password

  USER_COL.insert_one({name: username, pass: password})

  redirect to('/index')
end

get '/hello/:username' do | username |
  "Hello #{username}"
end
