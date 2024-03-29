# Smart AC Proof of Concept

## Device Message Examples

### Boot-up message

Upon boot up and before sending sensor readings, the AC unit should make an HTTP
post to the device registration endpoint `/api/devices/register` with the
following message:

```json
{
  "serial_number": "A123456",
  "firmware_version": "0.1.0"
}
```

### Boot-up message response

The registration endpoint will respond with a JSON body containing the
`device_id` that the AC unit should send in sensor messages and the
current time.

```json
{
  "device_id": "2d85fd01-9766-4996-85a3-50876558d8a0",
  "current_time": "2020-01-01T00:00:00+0000"
}
```

### Sensor-reading messages

Once a sensor reading is made, the AC unit should make an HTTP POST to the
device readings endpoint `/api/devices/readings`:

```json
{
  "device_id": "2d85fd01-9766-4996-85a3-50876558d8a0",
  "health_status": "needs_new_filter",
  "readings": [
    {
      "sequence_number": 1,
      "recorded_at": "2020-01-01T00:00:00+0000",
      "sensor_values": {
        "temperature_c": 30.0,
        "humidity_%": 25.0,
        "carbon_monoxide_ppm": 0.01
      }
    }
  ]
}
```

The server will respond with a 200 OK status code if the message is successfully
received.

## Questions

Q: Are the AC unit serial numbers guaranteed to be unique?

A: Yes

Q: How many AC units are deployed?

Q: Presumably the AC units speak HTTPS. What message protocol will the AC units speak? Binary protocol, XML, JSON or something else? Will different firmware versions have a different message protocol? For this POC, can I simply use a JSON protocol?

A: You can make them up, the idea would be that you are proposing how these would look like since the client hasn’t been built yet and we have room for accommodating

## Had there been more time, I would have...

1. ...completed the charts for weekly, monthly, and yearly readings.
1. ...written some tests.
1. ...added a flexible rules-based approach to generating device alarms. I
   started designing this and abandoned it due to time.
1. ...used fancier Postgresql functions for maintaining a moving average. I'm
   not as familiar with those tools, but I know they exist and would have
   investigated using them had there been more time.
1. ...renamed the models `DeviceAlarm` and `DeviceMessageReading` to something
   shorter.
1. ...implemented a better JS-based frontend. I looked briefly into React for
   charting and alarm management, but took the absolutely fastest JS approach I
   could: pure JS and short polling.
1. ...rewritten the UI to use flexbox or css grid instead of adding Bootstrap.
   I didn't think I had time to get my own grid going, and Bootstrap just works.
