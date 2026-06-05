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

ActiveRecord::Schema[7.1].define(version: 2026_06_11_000201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.date "check_in", null: false
    t.date "check_out", null: false
    t.integer "guests_count", default: 1, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.text "special_requests"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_in", "check_out"], name: "index_bookings_on_check_in_and_check_out"
    t.index ["room_id", "check_in", "check_out"], name: "index_bookings_on_room_and_dates"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "check_out > check_in", name: "chk_bookings_checkout_after_checkin"
    t.check_constraint "guests_count > 0", name: "chk_bookings_guests_count_positive"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'confirmed'::character varying::text, 'cancelled'::character varying::text, 'completed'::character varying::text])", name: "chk_bookings_status_values"
    t.check_constraint "total_price > 0::numeric", name: "chk_bookings_total_price_positive"
    t.exclusion_constraint "room_id WITH =, daterange(check_in, check_out) WITH &&", where: "(status)::text <> 'cancelled'::text", using: :gist, name: "excl_bookings_no_overlap"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hotel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hotel_id"], name: "index_favorites_on_hotel_id"
    t.index ["user_id", "hotel_id"], name: "index_favorites_on_user_and_hotel", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "hotel_type"
    t.string "city"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.decimal "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "chain"
    t.bigint "user_id"
    t.string "status", default: "review", null: false
    t.decimal "base_price_per_night"
    t.date "available_from"
    t.date "available_to"
    t.string "check_in_time", default: "14:00"
    t.string "check_out_time", default: "12:00"
    t.text "amenities", default: [], array: true
    t.text "rules"
    t.string "image_url"
    t.text "deletion_reason"
    t.index ["status"], name: "index_hotels_on_status"
    t.index ["user_id"], name: "index_hotels_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text, 'deleted'::text])", name: "chk_hotels_status_values"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.boolean "read", default: false, null: false
    t.bigint "booking_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_notifications_on_booking_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "property_type"
    t.string "city"
    t.string "address"
    t.integer "rooms_count"
    t.decimal "area"
    t.integer "guests_capacity"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "review", null: false
    t.decimal "base_price_per_night"
    t.date "available_from"
    t.date "available_to"
    t.string "check_in_time", default: "14:00"
    t.string "check_out_time", default: "12:00"
    t.text "amenities", default: [], array: true
    t.text "rules"
    t.string "image_url"
    t.text "deletion_reason"
    t.index ["status"], name: "index_properties_on_status"
    t.index ["user_id"], name: "index_properties_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text, 'deleted'::text])", name: "chk_properties_status_values"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hotel_id", null: false
    t.bigint "booking_id"
    t.integer "rating", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["hotel_id"], name: "index_reviews_on_hotel_id"
    t.index ["user_id", "booking_id"], name: "index_reviews_on_user_and_booking", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "chk_reviews_rating_range"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.string "room_type"
    t.integer "capacity"
    t.decimal "area"
    t.decimal "price_per_night"
    t.text "description"
    t.boolean "available"
    t.bigint "hotel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "view_type", default: "Во двор"
    t.text "amenities", default: [], array: true
    t.string "image_url"
    t.index ["hotel_id"], name: "index_rooms_on_hotel_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "city"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.check_constraint "role::text = ANY (ARRAY['user'::character varying::text, 'supervisor'::character varying::text, 'admin'::character varying::text])", name: "chk_users_role_values"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "users"
  add_foreign_key "favorites", "hotels"
  add_foreign_key "favorites", "users"
  add_foreign_key "hotels", "users"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "hotels"
  add_foreign_key "reviews", "users"
  add_foreign_key "rooms", "hotels"
end
