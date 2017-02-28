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

ActiveRecord::Schema.define(version: 20170228215701) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applicants", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.text     "intro"
    t.string   "status"
    t.string   "city"
    t.integer  "age"
    t.string   "preferred_locations"
    t.string   "how_did_you_hear"
    t.boolean  "work_authorization"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "beta_users", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "user_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_number"
  end

  create_table "blogs", force: :cascade do |t|
    t.string   "author"
    t.string   "title"
    t.date     "published"
    t.text     "content"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
  end

  create_table "calendar_blocks", force: :cascade do |t|
    t.integer  "instructor_id"
    t.integer  "lesson_time_id"
    t.string   "status",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size"
    t.string   "data_fingerprint",  limit: 255
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "instructor_id"
    t.integer  "requester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "instructors", force: :cascade do |t|
    t.string   "first_name",              limit: 255
    t.string   "last_name",               limit: 255
    t.string   "username",                limit: 255
    t.string   "certification",           limit: 255
    t.string   "phone_number",            limit: 255
    t.string   "preferred_locations",     limit: 255
    t.string   "sport",                   limit: 255
    t.text     "bio"
    t.text     "intro"
    t.string   "status",                  limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city",                    limit: 255
    t.integer  "adults_initial_rank"
    t.integer  "kids_initial_rank"
    t.integer  "overall_initial_rank"
    t.string   "avatar_file_name",        limit: 255
    t.string   "avatar_content_type",     limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "how_did_you_hear",        limit: 255
    t.string   "confirmed_certification", limit: 255
    t.boolean  "kids_eligibility"
    t.boolean  "seniors_eligibility"
    t.boolean  "adults_eligibility"
    t.integer  "age"
    t.date     "dob"
  end

  create_table "instructors_locations", id: false, force: :cascade do |t|
    t.integer "instructor_id", null: false
    t.integer "location_id",   null: false
  end

  create_table "instructors_ski_levels", id: false, force: :cascade do |t|
    t.integer "instructor_id", null: false
    t.integer "ski_level_id",  null: false
  end

  create_table "instructors_snowboard_levels", id: false, force: :cascade do |t|
    t.integer "instructor_id",      null: false
    t.integer "snowboard_level_id", null: false
  end

  create_table "instructors_sports", id: false, force: :cascade do |t|
    t.integer "instructor_id", null: false
    t.integer "sport_id",      null: false
  end

  create_table "lesson_actions", force: :cascade do |t|
    t.integer  "lesson_id"
    t.integer  "instructor_id"
    t.string   "action",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_times", force: :cascade do |t|
    t.date   "date"
    t.string "slot", limit: 255
  end

  create_table "lessons", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "instructor_id"
    t.string   "ability_level",                   limit: 255
    t.string   "deposit_status",                  limit: 255
    t.integer  "lesson_time_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity",                        limit: 255
    t.string   "requested_location",              limit: 255
    t.string   "phone_number",                    limit: 255
    t.boolean  "gear"
    t.text     "objectives"
    t.string   "state",                           limit: 255
    t.integer  "duration"
    t.string   "start_time",                      limit: 255
    t.string   "actual_start_time",               limit: 255
    t.string   "actual_end_time",                 limit: 255
    t.float    "actual_duration"
    t.boolean  "terms_accepted"
    t.text     "public_feedback_for_student"
    t.text     "private_feedback_for_student"
    t.string   "focus_area",                      limit: 255
    t.string   "lift_ticket_status"
    t.string   "guest_email"
    t.string   "how_did_you_hear"
    t.integer  "num_days"
    t.decimal  "lesson_price"
    t.string   "requester_name"
    t.boolean  "is_gift_voucher",                             default: false
    t.boolean  "includes_lift_or_rental_package",             default: false
    t.text     "package_info"
    t.string   "gift_recipient_email"
    t.string   "gift_recipient_name"
    t.decimal  "lesson_cost"
    t.decimal  "non_lesson_cost"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "partner_status",    limit: 255
    t.string   "calendar_status",   limit: 255
    t.string   "region",            limit: 255
    t.string   "state",             limit: 255
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "vertical_feet"
    t.integer  "base_elevation"
    t.integer  "peak_elevation"
    t.integer  "skiable_acres"
    t.integer  "average_snowfall"
    t.integer  "lift_count"
    t.string   "address",           limit: 255
    t.boolean  "night_skiing"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "conversation_id"
    t.text     "content"
    t.boolean  "unread"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pre_season_location_requests", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.float    "price"
    t.integer  "location_id"
    t.string   "calendar_period",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "length",                        limit: 255
    t.string   "slot",                          limit: 255
    t.string   "start_time",                    limit: 255
    t.string   "product_type",                  limit: 255
    t.boolean  "is_lesson",                                 default: false
    t.boolean  "is_private_lesson",                         default: false
    t.boolean  "is_group_lesson",                           default: false
    t.boolean  "is_lift_ticket",                            default: false
    t.boolean  "is_rental",                                 default: false
    t.boolean  "is_lift_rental_package",                    default: false
    t.boolean  "is_lift_lesson_package",                    default: false
    t.boolean  "is_lift_lesson_rental_package",             default: false
    t.boolean  "is_multi_day",                              default: false
    t.string   "age_type",                      limit: 255
    t.text     "details"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "instructor_id"
    t.integer  "lesson_id"
    t.integer  "reviewer_id"
    t.integer  "rating"
    t.text     "review"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nps"
  end

  create_table "ski_levels", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snowboard_levels", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sports", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.integer "lesson_id"
    t.string  "name",                      limit: 255
    t.string  "age_range",                 limit: 255
    t.string  "gender",                    limit: 255
    t.string  "lesson_history",            limit: 255
    t.string  "experience",                limit: 255
    t.string  "relationship_to_requester", limit: 255
    t.integer "requester_id"
    t.string  "most_recent_experience",    limit: 255
    t.string  "most_recent_level",         limit: 255
    t.text    "other_sports_experience"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "lesson_id"
    t.integer  "requester_id"
    t.float    "base_amount"
    t.float    "tip_amount"
    t.float    "final_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "image",                  limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "user_type",              limit: 255
    t.integer  "location_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

end
