class CreateDeviceMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :device_messages do |t|
      t.references :device, null: false, foreign_key: { on_delete: :cascade }
      t.string :health_status
      t.timestamp :recorded_at, null: false
      t.timestamp :received_at, null: false

      t.timestamps
    end

    create_table :sensor_types do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :units, null: false

      t.timestamps
    end

    create_table :device_message_readings do |t|
      t.references :sensor_type, null: false, foreign_key: { on_delete: :cascade }
      t.references :device_message, null: false, foreign_key: { on_delete: :cascade }
      t.float :value, null: false

      t.timestamps
    end

    add_reference :devices, :latest_device_message, foreign_key: { to_table: :device_message_readings, on_delete: :nullify }
  end
end
