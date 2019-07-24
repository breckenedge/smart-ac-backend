class CreateDeviceReadingAverages < ActiveRecord::Migration***REMOVED***5.2]
  def change
    create_table :device_reading_hourly_averages do |t|
      t.references :first_device_message, null: false, foreign_key: { to_table: :device_messages, on_delete: :cascade }
      t.references :device, null: false, foreign_key: { on_delete: :cascade }
      t.references :sensor_type, null: false, foreign_key: { on_delete: :cascade }
      t.timestamp :hour, null: false
      t.float :average, default: 0.0, null: false
      t.integer :count, default: 0

      t.timestamps
  ***REMOVED***

    create_table :device_reading_daily_averages do |t|
      t.references :first_device_message, null: false, foreign_key: { to_table: :device_messages, on_delete: :cascade }
      t.references :device, null: false, foreign_key: { on_delete: :cascade }
      t.references :sensor_type, null: false, foreign_key: { on_delete: :cascade }
      t.date :date, null: false
      t.float :average, default: 0.0, null: false
      t.integer :count, default: 0

      t.timestamps
  ***REMOVED***
***REMOVED***
***REMOVED***
