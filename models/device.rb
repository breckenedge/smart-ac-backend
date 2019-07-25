class Device < ActiveRecord::Base
  validates :serial_number, presence: true, uniqueness: true
  validates :registration_date, presence: true
  validates :firmware_version, presence: true

  belongs_to :latest_device_message, class_name: 'DeviceMessage'
  has_many :device_messages, dependent: :delete_all
  has_many :device_alarms, dependent: :delete_all

  def latest_health_status
    latest_device_message&.health_status
  end

  def latest_device_message_recorded_at
    latest_device_message&.recorded_at
  end
end
