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
***REMOVED***

  before do
    if !current_user
      redirect '/login' unless request.path == '/login' || request.path.starts_with?('/api')
  ***REMOVED***
***REMOVED***

  get '/' do
    if logged_in?
      redirect '/devices'
    else
      redirect '/login'
  ***REMOVED***
***REMOVED***

  get '/login' do
    erb :login, login: Login.new
***REMOVED***

  post '/login' do
    login = Login.new(params)
    if login.authenticated?
      session***REMOVED***:user_id] = login.user_id
      redirect '/devices'
    else
      erb :login, login: Login.new
  ***REMOVED***
***REMOVED***

  get '/logout' do
    session***REMOVED***:user_id] = nil
    redirect '/'
***REMOVED***

  get '/alarms' do
    erb :alarms, locals: { alarms: all_alarms }
***REMOVED***

  get '/alarms/unresolved' do
    content_type :json
    unresolved_alarms.map do |alarm|
      {
        'name' => alarm.name,
        'serial_number' => alarm.device.serial_number,
        'href' => "/alarms/#{alarm.id}"
      }
  ***REMOVED***.to_json
***REMOVED***

  get '/alarms/:id' do
    erb :alarm, locals: { alarm: find_alarm(params***REMOVED***:id]) }
***REMOVED***

  post '/alarms/:id/resolve' do
    alarm = find_alarm(params***REMOVED***:id])
    alarm.update!(resolved: true)
    redirect '/alarms'
***REMOVED***

  get '/devices' do
    erb :devices, locals: { devices: all_devices }
***REMOVED***

  get '/devices/new' do
    erb :edit_device, locals: { device: Device.new }
***REMOVED***

  get '/devices/search' do
    erb :devices, locals: { devices: search_all_devices(params***REMOVED***:q]) }
***REMOVED***

  post '/devices' do
    device = Device.new(params.slice('serial_number', 'registration_date', 'firmware_version'))
    device.uuid = SecureRandom.uuid
    if device.save
      redirect "/devices/#{device.id}"
    else
      erb :edit_device, locals: { device: Device.new }
  ***REMOVED***
***REMOVED***

  get '/devices/:id' do
    device = find_device(params***REMOVED***:id])
    erb :device, locals: {
***REMOVED***
      latest_device_message_health_status: device.latest_device_message&.health_status,
      latest_device_message_readings: device.latest_device_message&.device_message_readings || ***REMOVED***]
    }
***REMOVED***

  get '/devices/:id/edit' do
    device = find_device(params***REMOVED***:id])
    erb :edit_device, locals: { device: device }
***REMOVED***

  post '/devices/:id' do
    device = find_device(params***REMOVED***:id])
    if params***REMOVED***'delete'] == '1'
      device.delete
      redirect '/devices'
    elsif device.update(params.slice('registration_date', 'firmware_version'))
      redirect "/devices/#{device.id}"
    else
      r***REMOVED***er :edit_device, locals: { device: device }
  ***REMOVED***
***REMOVED***

  get '/devices/:id/readings.csv' do
    device = find_device(params***REMOVED***:id])
    content_type 'text/csv'
    DeviceReadingsChartDataPresenter.new(device: device, term: params***REMOVED***:term]).to_csv
***REMOVED***

  get '/devices/:id/reading_averages_by_hour.csv' do

***REMOVED***

  get '/devices/:id/reading_averages_by_day.csv' do

***REMOVED***

  get '/users' do
    erb :users, locals: { users: all_users }
***REMOVED***

  post '/users' do
    user = User.new(params.slice('forename', 'surname', 'email'))
    if user.save
      redirect "/users/#{user.id}"
    else
      erb :edit_user, locals: { user: user }
  ***REMOVED***
***REMOVED***

  get '/users/new' do
    user = User.new
    erb :edit_user, locals: { user: user }
***REMOVED***

  get '/users/:id' do
    user = find_user(params***REMOVED***:id])
    erb :user, locals: { user: user }
***REMOVED***

  get '/users/:id/edit' do
    user = find_user(params***REMOVED***:id])
    erb :edit_user, locals: { user: user }
***REMOVED***

  post '/users/:id' do
    user = find_user(params***REMOVED***:id])
    if params***REMOVED***'delete'] == '1'
      user.delete
      redirect '/users'
    elsif user.update(params.slice('forename', 'surname', 'email'))
      redirect "/users/#{user.id}"
    else
      erb :edit_user, locals: { user: user }
  ***REMOVED***
***REMOVED***

  post '/api/devices/register' do
    content_type :json
    json = JSON.parse(request.body.read)
    consumer = DeviceRegistrationMessageConsumer.new

    if (device = consumer.consume(json.slice('serial_number', 'firmware_version')))
      { device_id: device.uuid, current_time: Time.now.iso8601 }.to_json
    else
      status 422
      { error: 'Unable to register device' }.to_json
  ***REMOVED***
***REMOVED***

  post '/api/devices/readings' do
    content_type :json
    json = JSON.parse(request.body.read)
    consumer = DeviceReadingsMessageConsumer.new

    if consumer.consume(json)
      status 200
    else
      status 422
      { error: 'Unable to save readings' }.to_json
  ***REMOVED***
***REMOVED***

  def all_alarms
    DeviceAlarm.order(created_at: :desc)
***REMOVED***

  def all_devices
    Device.order(serial_number: :asc)
***REMOVED***

  def all_users
    User.order(:surname, :forename)
***REMOVED***

  def find_alarm(id)
    DeviceAlarm.find(id)
***REMOVED***

  def find_device(id)
    Device.find(id)
***REMOVED***

  def find_user(id)
    User.find(id)
***REMOVED***

  def search_all_devices(query)
    Device.where('serial_number LIKE ?', "%#{query}%")
***REMOVED***

  def unresolved_alarms
    DeviceAlarm.where(resolved: false)
***REMOVED***

  helpers do
    def logged_in?
      !session***REMOVED***:user_id].nil?
  ***REMOVED***

    def current_user
      session***REMOVED***:user_id] ? find_user(session***REMOVED***:user_id]) : nil
  ***REMOVED***

    def format_date(date)
      date&.strftime('%d %b %Y')
  ***REMOVED***

    def format_time(time)
      time&.strftime('%d %b %Y %H:%M:%S %p %Z')
  ***REMOVED***
***REMOVED***
***REMOVED***
