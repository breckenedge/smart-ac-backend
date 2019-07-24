class DeviceMessage < ActiveRecord::Base
  belongs_to :device
  has_many :device_message_readings
***REMOVED***
