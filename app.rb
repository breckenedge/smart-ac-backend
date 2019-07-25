require 'pg'
require 'securerandom'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'sinatra/reloader'
require_relative './models/device'
require_relative './models/device_alarm'
require_relative './models/device_message'
require_relative './models/device_message_reading'
require_relative './models/device_reading_daily_average'
require_relative './models/device_reading_hourly_average'
require_relative './models/login'
require_relative './models/user'
require_relative './models/sensor_type'
require_relative './lib/device_registration_message_consumer'
require_relative './lib/device_readings_message_consumer'
require_relative './lib/device_readings_chart_data_presenter'

class App < Sinatra::Base
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  set :views, 'views'
  set :public_folder, 'public'

  configure :development do
    register Sinatra::Reloader
  end

  before do
    if !current_user
      redirect '/login' unless request.path == '/login' || request.path.starts_with?('/api')
    end
  end

  get '/' do
    if logged_in?
      redirect '/devices'
    else
      redirect '/login'
    end
  end

  get '/login' do
    erb :login, login: Login.new
  end

  post '/login' do
    login = Login.new(params)
    if login.authenticated?
      session[:user_id] = login.user_id
      redirect '/devices'
    else
      erb :login, login: Login.new
    end
  end

  get '/logout' do
    session[:user_id] = nil
    redirect '/'
  end

  get '/alarms' do
    erb :alarms, locals: { alarms: all_alarms }
  end

  get '/alarms/unresolved' do
    content_type :json
    unresolved_alarms.map do |alarm|
      {
        'name' => alarm.name,
        'serial_number' => alarm.device.serial_number,
        'href' => "/alarms/#{alarm.id}"
      }
    end.to_json
  end

  get '/alarms/:id' do
    erb :alarm, locals: { alarm: find_alarm(params[:id]) }
  end

  post '/alarms/:id/resolve' do
    alarm = find_alarm(params[:id])
    alarm.update!(resolved: true)
    redirect '/alarms'
  end

  get '/devices' do
    erb :devices, locals: { devices: all_devices }
  end

  get '/devices/new' do
    erb :edit_device, locals: { device: Device.new }
  end

  get '/devices/search' do
    erb :devices, locals: { devices: search_all_devices(params[:q]) }
  end

  post '/devices' do
    device = Device.new(params.slice('serial_number', 'registration_date', 'firmware_version'))
    device.uuid = SecureRandom.uuid
    if device.save
      redirect "/devices/#{device.id}"
    else
      erb :edit_device, locals: { device: Device.new }
    end
  end

  get '/devices/:id' do
    device = find_device(params[:id])
    erb :device, locals: {
      device: device,
      latest_device_message_health_status: device.latest_device_message&.health_status,
      latest_device_message_readings: device.latest_device_message&.device_message_readings || []
    }
  end

  get '/devices/:id/edit' do
    device = find_device(params[:id])
    erb :edit_device, locals: { device: device }
  end

  post '/devices/:id' do
    device = find_device(params[:id])
    if params['delete'] == '1'
      device.delete
      redirect '/devices'
    elsif device.update(params.slice('registration_date', 'firmware_version'))
      redirect "/devices/#{device.id}"
    else
      render :edit_device, locals: { device: device }
    end
  end

  get '/devices/:id/readings.csv' do
    device = find_device(params[:id])
    content_type 'text/csv'
    DeviceReadingsChartDataPresenter.new(device: device, term: params[:term]).to_csv
  end

  get '/devices/:id/reading_averages_by_hour.csv' do

  end

  get '/devices/:id/reading_averages_by_day.csv' do

  end

  get '/users' do
    erb :users, locals: { users: all_users }
  end

  post '/users' do
    user = User.new(params.slice('forename', 'surname', 'email'))
    if user.save
      redirect "/users/#{user.id}"
    else
      erb :edit_user, locals: { user: user }
    end
  end

  get '/users/new' do
    user = User.new
    erb :edit_user, locals: { user: user }
  end

  get '/users/:id' do
    user = find_user(params[:id])
    erb :user, locals: { user: user }
  end

  get '/users/:id/edit' do
    user = find_user(params[:id])
    erb :edit_user, locals: { user: user }
  end

  post '/users/:id' do
    user = find_user(params[:id])
    if params['delete'] == '1'
      user.delete
      redirect '/users'
    elsif user.update(params.slice('forename', 'surname', 'email'))
      redirect "/users/#{user.id}"
    else
      erb :edit_user, locals: { user: user }
    end
  end

  post '/api/devices/register' do
    content_type :json
    json = JSON.parse(request.body.read)
    consumer = DeviceRegistrationMessageConsumer.new

    if (device = consumer.consume(json.slice('serial_number', 'firmware_version')))
      { device_id: device.uuid, current_time: Time.now.iso8601 }.to_json
    else
      status 422
      { error: 'Unable to register device' }.to_json
    end
  end

  post '/api/devices/readings' do
    content_type :json
    json = JSON.parse(request.body.read)
    consumer = DeviceReadingsMessageConsumer.new

    if consumer.consume(json)
      status 200
    else
      status 422
      { error: 'Unable to save readings' }.to_json
    end
  end

  def all_alarms
    DeviceAlarm.order(created_at: :desc)
  end

  def all_devices
    Device.order(serial_number: :asc)
  end

  def all_users
    User.order(:surname, :forename)
  end

  def find_alarm(id)
    DeviceAlarm.find(id)
  end

  def find_device(id)
    Device.find(id)
  end

  def find_user(id)
    User.find(id)
  end

  def search_all_devices(query)
    Device.where('serial_number LIKE ?', "%#{query}%")
  end

  def unresolved_alarms
    DeviceAlarm.where(resolved: false)
  end

  helpers do
    def logged_in?
      !session[:user_id].nil?
    end

    def current_user
      session[:user_id] ? find_user(session[:user_id]) : nil
    end

    def format_date(date)
      date&.strftime('%d %b %Y')
    end

    def format_time(time)
      time&.strftime('%d %b %Y %H:%M:%S %p %Z')
    end
  end
end
