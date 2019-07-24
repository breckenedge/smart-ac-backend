class CreateDevices < ActiveRecord::Migration***REMOVED***5.2]
  def change
    create_table :devices do |t|
      t.string :uuid, null: false, index: { unique: true }
      t.string :serial_number, null: false, index: { unique: true }
      t.string :firmware_version, null: false
      t.date :registration_date, null: false

      t.timestamps
  ***REMOVED***
***REMOVED***
***REMOVED***
