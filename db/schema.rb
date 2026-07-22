# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_22_034608) do
  create_table "action_logs", force: :cascade do |t|
    t.string "action_name"
    t.datetime "created_at", null: false
    t.integer "loggable_id", null: false
    t.string "loggable_type", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["loggable_type", "loggable_id"], name: "index_action_logs_on_loggable"
    t.index ["user_id"], name: "index_action_logs_on_user_id"
  end

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.integer "status", default: 10, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["status"], name: "index_articles_on_status"
    t.index ["user_id", "status"], name: "index_articles_on_user_id_and_status"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "email_verified_at"
    t.string "name", null: false
    t.string "password_digest", default: "", null: false
    t.integer "published_articles_count", default: 0, null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "action_logs", "users"
  add_foreign_key "articles", "users"
  add_foreign_key "user_profiles", "users"
end
