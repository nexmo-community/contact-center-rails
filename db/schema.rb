# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_18_143316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_logs", force: :cascade do |t|
    t.string "event_type"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "nexmo_apps", force: :cascade do |t|
    t.string "app_id"
    t.string "name"
    t.text "public_key"
    t.text "private_key"
    t.string "voice_answer_url"
    t.string "voice_answer_method"
    t.string "voice_event_url"
    t.string "voice_event_method"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number_msisdn"
    t.string "number_country"
    t.integer "voice_answer_type", default: 0
    t.text "voice_answer_custom_ncco", default: "[]"
    t.index ["app_id"], name: "index_nexmo_apps_on_app_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "user_id"
    t.text "user_name"
    t.text "jwt"
    t.datetime "jwt_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

end
