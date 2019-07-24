class CreateDeviceAlarms < ActiveRecord::Migration***REMOVED***5.2]
  def change
    create_table :device_alarms do |t|
      t.string :name, null: false
      t.references :device, foreign_key: { on_delete: :cascade }
      t.references :initial_device_message, foreign_key: { to_table: :device_messages, on_delete: :nullify }
      t.boolean :resolved, null: false, default: false

      t.timestamps
  ***REMOVED***
***REMOVED***
***REMOVED***
