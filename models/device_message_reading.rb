class DeviceMessageReading < ActiveRecord::Base
  belongs_to :device_message
  belongs_to :sensor_type

  delegate :device, to: :device_message

  def recorded_at
    device_message&.recorded_at
  end

  def recorded_on
    recorded_at&.to_date
  end
end
