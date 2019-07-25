# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_24_234519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "device_alarms", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "device_id"
    t.bigint "initial_device_message_id"
    t.boolean "resolved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_alarms_on_device_id"
    t.index ["initial_device_message_id"], name: "index_device_alarms_on_initial_device_message_id"
  end

  create_table "device_message_readings", force: :cascade do |t|
    t.bigint "sensor_type_id", null: false
    t.bigint "device_message_id", null: false
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_message_id"], name: "index_device_message_readings_on_device_message_id"
    t.index ["sensor_type_id"], name: "index_device_message_readings_on_sensor_type_id"
  end

  create_table "device_messages", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.string "health_status"
    t.datetime "recorded_at", null: false
    t.datetime "received_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_messages_on_device_id"
  end

  create_table "device_reading_daily_averages", force: :cascade do |t|
    t.bigint "first_device_message_id", null: false
    t.bigint "device_id", null: false
    t.bigint "sensor_type_id", null: false
    t.date "date", null: false
    t.float "average", default: 0.0, null: false
    t.integer "count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_reading_daily_averages_on_device_id"
    t.index ["first_device_message_id"], name: "index_device_reading_daily_averages_on_first_device_message_id"
    t.index ["sensor_type_id"], name: "index_device_reading_daily_averages_on_sensor_type_id"
  end

  create_table "device_reading_hourly_averages", force: :cascade do |t|
    t.bigint "first_device_message_id", null: false
    t.bigint "device_id", null: false
    t.bigint "sensor_type_id", null: false
    t.datetime "hour", null: false
    t.float "average", default: 0.0, null: false
    t.integer "count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_reading_hourly_averages_on_device_id"
    t.index ["first_device_message_id"], name: "index_device_reading_hourly_averages_on_first_device_message_id"
    t.index ["sensor_type_id"], name: "index_device_reading_hourly_averages_on_sensor_type_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "serial_number", null: false
    t.string "firmware_version", null: false
    t.date "registration_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "latest_device_message_id"
    t.index ["latest_device_message_id"], name: "index_devices_on_latest_device_message_id"
    t.index ["serial_number"], name: "index_devices_on_serial_number", unique: true
    t.index ["uuid"], name: "index_devices_on_uuid", unique: true
  end

  create_table "sensor_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "units", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sensor_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "forename"
    t.string "surname"
    t.string "email", null: false
    t.string "password_digest"
    t.boolean "locked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "device_alarms", "device_messages", column: "initial_device_message_id", on_delete: :nullify
  add_foreign_key "device_alarms", "devices", on_delete: :cascade
  add_foreign_key "device_message_readings", "device_messages", on_delete: :cascade
  add_foreign_key "device_message_readings", "sensor_types", on_delete: :cascade
  add_foreign_key "device_messages", "devices", on_delete: :cascade
  add_foreign_key "device_reading_daily_averages", "device_messages", column: "first_device_message_id", on_delete: :cascade
  add_foreign_key "device_reading_daily_averages", "devices", on_delete: :cascade
  add_foreign_key "device_reading_daily_averages", "sensor_types", on_delete: :cascade
  add_foreign_key "device_reading_hourly_averages", "device_messages", column: "first_device_message_id", on_delete: :cascade
  add_foreign_key "device_reading_hourly_averages", "devices", on_delete: :cascade
  add_foreign_key "device_reading_hourly_averages", "sensor_types", on_delete: :cascade
  add_foreign_key "devices", "device_message_readings", column: "latest_device_message_id", on_delete: :nullify
end
