require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'mongoid'
require 'bcrypt'
require_relative 'user'

configure do
  enable :sessions
  Mongoid.load!('./config/mongoid.yml', :development)
  set :public_folder, File.dirname(__FILE__) + '/public'
end

get '/' do
  redirect to('/index')
end

get '/index' do
  if session[:user] then
    @user_name = session[:user].name
    for task in Task.where(name: @user_name)
      p task
      p task[:name]
      @task_name = task.task_name
      @task_log = task.task_log
      p @task_log
    end

    #if i @task_name = task[:task_name]
    #  @task_log = task[:task_log]
    #else
    #  task = Task.new(name: @user_name, task_name: "task")
    #  @task_name = task.task_name
    #  @task_log = task.task_log
    #end
    erb :index
  elsif
    redirect to('/login')
  end
end

get '/login' do
  @isFailed = false
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

  user = User.authenticate(params[:username], params[:password])
  if user
    session[:user] = user
    redirect to("/index")
  else
    @isFailed  = true
    erb :login
  end
end

get '/register' do
  @isFailed = false
  erb :register
end

post '/register' do
  user = User.new(name: params[:username])
  user.encrypt_password(params[:password])
  begin
    user.save!
    task = Task.new(name: user.name, task_name: "hage")

    task.save!
    session[:user] = user
    redirect to("/index")
  rescue => e
    p e
    @isFailed = true
    erb :register
  end
end

get '/hello/:username' do | username |
  "Hello #{username}"
end
