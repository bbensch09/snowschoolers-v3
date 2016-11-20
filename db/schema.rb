# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161120010929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beta_users", force: true do |t|
    t.string   "email"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calendar_blocks", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "lesson_time_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "data_fingerprint"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "conversations", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "requester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "instructors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "certification"
    t.string   "phone_number"
    t.string   "preferred_locations"
    t.string   "sport"
    t.text     "bio"
    t.text     "intro"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.integer  "adults_initial_rank"
    t.integer  "kids_initial_rank"
    t.integer  "overall_initial_rank"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "how_did_you_hear"
    t.string   "confirmed_certification"
    t.boolean  "kids_eligibility"
    t.boolean  "seniors_eligibility"
    t.boolean  "adults_eligibility"
    t.integer  "age"
    t.date     "dob"
  end

  create_table "instructors_locations", id: false, force: true do |t|
    t.integer "instructor_id", null: false
    t.integer "location_id",   null: false
  end

  create_table "instructors_ski_levels", id: false, force: true do |t|
    t.integer "instructor_id", null: false
    t.integer "ski_level_id",  null: false
  end

  create_table "instructors_snowboard_levels", id: false, force: true do |t|
    t.integer "instructor_id",      null: false
    t.integer "snowboard_level_id", null: false
  end

  create_table "lesson_actions", force: true do |t|
    t.integer  "lesson_id"
    t.integer  "instructor_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_times", force: true do |t|
    t.date   "date"
    t.string "slot"
  end

  create_table "lessons", force: true do |t|
    t.integer  "requester_id"
    t.integer  "instructor_id"
    t.string   "ability_level"
    t.string   "deposit_status"
    t.integer  "lesson_time_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity"
    t.string   "requested_location"
    t.string   "phone_number"
    t.boolean  "gear"
    t.text     "objectives"
    t.string   "state"
    t.integer  "duration"
    t.string   "start_time"
    t.string   "actual_start_time"
    t.string   "actual_end_time"
    t.float    "actual_duration"
    t.boolean  "terms_accepted"
    t.string   "public_feedback_for_student"
    t.string   "private_feedback_for_student"
    t.string   "focus_area"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "partner_status"
    t.string   "calendar_status"
    t.string   "region"
    t.string   "state"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "vertical_feet"
    t.integer  "base_elevation"
    t.integer  "peak_elevation"
    t.integer  "skiable_acres"
    t.integer  "average_snowfall"
    t.integer  "lift_count"
    t.string   "address"
    t.boolean  "night_skiing"
  end

  create_table "messages", force: true do |t|
    t.integer  "author_id"
    t.integer  "conversation_id"
    t.text     "content"
    t.boolean  "unread"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pre_season_location_requests", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.integer  "location_id"
    t.string   "calendar_period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "length"
    t.string   "slot"
    t.string   "start_time"
    t.string   "product_type"
    t.boolean  "is_lesson",                     default: false
    t.boolean  "is_private_lesson",             default: false
    t.boolean  "is_group_lesson",               default: false
    t.boolean  "is_lift_ticket",                default: false
    t.boolean  "is_rental",                     default: false
    t.boolean  "is_lift_rental_package",        default: false
    t.boolean  "is_lift_lesson_package",        default: false
    t.boolean  "is_lift_lesson_rental_package", default: false
    t.boolean  "is_multi_day",                  default: false
    t.string   "age_type"
    t.text     "details"
  end

  create_table "reviews", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "lesson_id"
    t.integer  "reviewer_id"
    t.integer  "rating"
    t.text     "review"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ski_levels", force: true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snowboard_levels", force: true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", force: true do |t|
    t.integer "lesson_id"
    t.string  "name"
    t.string  "age_range"
    t.string  "gender"
    t.string  "lesson_history"
    t.string  "experience"
    t.string  "relationship_to_requester"
    t.integer "requester_id"
    t.string  "most_recent_experience"
    t.string  "most_recent_level"
    t.text    "other_sports_experience"
  end

  create_table "transactions", force: true do |t|
    t.integer  "lesson_id"
    t.integer  "requester_id"
    t.float    "base_amount"
    t.float    "tip_amount"
    t.float    "final_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "user_type"
    t.integer  "location_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
