require 'date'
require 'sinatra'
require 'sinatra/reloader'
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
    @task_name = []
    @task_log = []
    for task in Task.where(name: @user_name)
      @task_name.push(task.task_name)
      @task_log.push(task.task_log)
    end
    erb :index
  else
    redirect to('/welcome')
  end
end

get '/home/:username' do
  if session[:user] then
    @user_name = session[:user].name
    @task_name = []
    @task_log = []
    for task in Task.where(name: @user_name)
      @task_name.push(task.task_name)
      @task_log.push(task.task_log)
    end
    erb :home
  else
    redirect to('/welcome')
  end
end

get '/welcome' do
  erb :welcome
end

post '/add_task' do
  if session[:user] then
    begin
      new_task = Task.new(name: session[:user].name, task_name: params[:task_name])
      new_task.save!
    rescue => e
      p e
    end
    redirect to("/home/#{session[:user].name}")
  else
    redirect to('/welcome')
  end
end

post '/do_task' do
  if session[:user] then
    today = Date.today()
    p today.day, today.month
    p session[:user].name, params[:task_name]
    task = Task.where(name: session[:user].name, task_name: params[:task_name]).first
    # p task
    task.task_log[today.month - 1][today.day - 1] = 1
    task.save!
    p task
    redirect to('/index')
  else
    redirect to('/welcome')
  end
end

get '/login' do
  @isFailed = false
  erb :login
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
    redirect to("/home/#{session[:user].name}")
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
    session[:user] = user
    redirect to("/home/#{session[:user].name}")
  rescue => e
    p e
    @isFailed = true
    erb :register
  end
end

