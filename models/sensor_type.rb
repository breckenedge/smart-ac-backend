class SensorType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :device_message_readings, dep***REMOVED***ent: :delete_all
  has_many :device_reading_date_average, dep***REMOVED***ent: :delete_all
***REMOVED***
