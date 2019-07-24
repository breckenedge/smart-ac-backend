class DeviceReadingDailyAverage < ActiveRecord::Base
  belongs_to :first_device_message, class_name: 'DeviceMessage'
  belongs_to :sensor_type
  belongs_to :device
  validates :date, presence: true
***REMOVED***
