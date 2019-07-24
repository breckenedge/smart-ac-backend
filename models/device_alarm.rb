class DeviceAlarm < ActiveRecord::Base
  belongs_to :device
  validates :name, presence: true

  def device_serial_number
    device&.serial_number
***REMOVED***
***REMOVED***
