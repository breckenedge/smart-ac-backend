class SensorType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :device_message_readings, dependent: :delete_all
  has_many :device_reading_date_average, dependent: :delete_all
end
