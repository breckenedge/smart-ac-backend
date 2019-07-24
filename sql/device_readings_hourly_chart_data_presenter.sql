SELECT hours,
temp_readings.value AS temperature_c,
humidity_readings.value AS humidity_percent,
co_readings.value AS carbon_monoxide_ppm
FROM generate_series($1::timestamp, $2::timestamp, '1 hour') AS hours

LEFT OUTER JOIN device_reading_hourly_averages temp_readings
ON temp_readings.hour = hours
AND temp_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'temperature_c')

LEFT OUTER JOIN device_reading_hourly_averages humidity_readings
ON humidity_readings.hour = hours
AND humidity_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'humidity_%')

LEFT OUTER JOIN device_reading_hourly_averages co_readings
ON co_readings.hour = hours
AND co_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'carbon_monoxide_ppm')

WHERE recorded_at BETWEEN $1 AND $2 AND device_messages.device_id = $3
