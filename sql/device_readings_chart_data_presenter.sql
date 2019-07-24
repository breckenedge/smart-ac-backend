SELECT recorded_at,
temp_readings.value AS temperature_c,
humidity_readings.value AS humidity_percent,
co_readings.value AS carbon_monoxide_ppm
FROM device_messages

LEFT OUTER JOIN device_message_readings temp_readings
ON temp_readings.device_message_id = device_messages.id
AND temp_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'temperature_c')

LEFT OUTER JOIN device_message_readings humidity_readings
ON humidity_readings.device_message_id = device_messages.id
AND humidity_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'humidity_%')

LEFT OUTER JOIN device_message_readings co_readings
ON co_readings.device_message_id = device_messages.id
AND co_readings.sensor_type_id = (SELECT id FROM sensor_types WHERE name = 'carbon_monoxide_ppm')

WHERE recorded_at BETWEEN $1 AND $2 AND device_messages.device_id = $3
