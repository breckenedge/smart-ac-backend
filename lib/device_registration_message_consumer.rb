require 'securerandom'
require_relative '../models/device'

class DeviceRegistrationMessageConsumer
  def consume(message)
    device = find_or_initialize_device_by_serial_number(message***REMOVED***'serial_number'])
    device.firmware_version = message***REMOVED***'firmware_version']
    device.uuid ||= SecureRandom.uuid
    device.registration_date ||= Date.current
    device.save ? device : false
***REMOVED***

  private

  def find_or_initialize_device_by_serial_number(serial_number)
    Device.find_or_initialize_by(serial_number: serial_number)
***REMOVED***
***REMOVED***
