require_relative '../models/device'
require_relative '../models/device_message'
require_relative '../models/sensor_type'

class DeviceReadingsMessageConsumer
  def consume(message = {})
    return false unless device = find_device_by_device_id(message['device_id'])

    if message.key?('readings')
      device_messages = message['readings'].sort { |hash| hash['sequence_number'] }.map do |hash|
        message = DeviceMessage.create!(
          device: device,
          recorded_at: hash.fetch('recorded_at'),
          received_at: Time.now,
          health_status: message.fetch('health_status', '')
        )

        hash['sensor_values'].each do |key, value|
          next unless (sensor_type = SensorType.find_by(name: key))

          reading = DeviceMessageReading.create!(
            device_message: message,
            sensor_type: sensor_type,
            value: value
          )

          update_daily_average(reading)
          update_hourly_average(reading)
        end

        generate_alarms(message)

        message
      end

      device.update!(latest_device_message: device_messages.last)

      true
    else
      false
    end
  end

  private

  def update_daily_average(reading)
    average = DeviceReadingDailyAverage.find_or_initialize_by(
      date: reading.recorded_on,
      sensor_type: reading.sensor_type,
      device: reading.device
    )
    average.first_device_message ||= reading.device_message
    update_average_with_reading(average, reading)
  end

  def update_hourly_average(reading)
    average = DeviceReadingHourlyAverage.find_or_initialize_by(
      hour: reading.recorded_at.beginning_of_hour,
      sensor_type: reading.sensor_type,
      device: reading.device
    )
    average.first_device_message ||= reading.device_message
    update_average_with_reading(average, reading)
  end

  def update_average_with_reading(average, reading)
    last = average.average * average.count
    average.count += 1
    average.average = (last + reading.value) / average.count
    average.save!
  end

  def alarm_triggers
    {
      'gas_leak' => ->(message) { message.health_status == 'gas_leak' },
      'needs_service' => ->(message) { message.health_status == 'needs_service' },
      'needs_new_filter' => ->(message) { message.health_status == 'needs_new_filter' },
      'high_carbon_monoxide' => ->(message) do
        return unless (sensor_type = SensorType.find_by(name: 'carbon_monoxide_ppm'))

        message.device_message_readings.find_by(sensor_type: sensor_type)&.value > 9
      end
    }
  end

  def generate_alarms(message)
    unresolved_alarms = unresolved_alarms_for_device(message.device)

    alarm_triggers.reject { |name, _| unresolved_alarms.any? { |alarm| alarm.name == name } }
      .select { |_, trigger| trigger.call(message) }
      .each { |name, _| DeviceAlarm.create!(device: message.device, name: name) }
  end

  def unresolved_alarms_for_device(device)
    DeviceAlarm.where(device: device, resolved: false)
  end

  def find_device_by_device_id(device_id)
    Device.find_by(uuid: device_id)
  end
end
