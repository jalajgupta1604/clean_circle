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

ActiveRecord::Schema[8.0].define(version: 2026_03_13_125053) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "households", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "route_id", null: false
    t.text "address"
    t.string "building_name"
    t.string "unit_number"
    t.string "qr_code_token"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_households_on_route_id"
    t.index ["user_id"], name: "index_households_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "body"
    t.integer "notification_type"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pickups", force: :cascade do |t|
    t.bigint "household_id", null: false
    t.bigint "agent_id", null: false
    t.bigint "route_id", null: false
    t.integer "status"
    t.integer "pickup_type"
    t.decimal "estimated_volume"
    t.text "notes"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_pickups_on_agent_id"
    t.index ["household_id"], name: "index_pickups_on_household_id"
    t.index ["route_id"], name: "index_pickups_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.string "area"
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_routes_on_agent_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name", null: false
    t.integer "bucket_size", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.integer "status"
    t.date "starts_on"
    t.date "ends_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.integer "family_size", default: 1
    t.text "address"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "qr_code_token"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["qr_code_token"], name: "index_users_on_qr_code_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "transaction_type"
    t.string "description"
    t.string "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_wallet_transactions_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "households", "routes"
  add_foreign_key "households", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "pickups", "households"
  add_foreign_key "pickups", "routes"
  add_foreign_key "pickups", "users", column: "agent_id"
  add_foreign_key "routes", "users", column: "agent_id"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "wallet_transactions", "wallets"
  add_foreign_key "wallets", "users"
end
