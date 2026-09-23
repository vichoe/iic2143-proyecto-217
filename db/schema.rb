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

ActiveRecord::Schema[8.1].define(version: 2026_09_23_181430) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "author", null: false
    t.bigint "category_id", null: false
    t.integer "condition", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "language"
    t.integer "modality", default: 0, null: false
    t.integer "published_year"
    t.string "publisher"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_books_on_category_id"
    t.index ["status"], name: "index_books_on_status"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "exchange_requests", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "message"
    t.bigint "offered_book_id"
    t.bigint "requester_id", null: false
    t.datetime "responded_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_exchange_requests_on_book_id"
    t.index ["offered_book_id"], name: "index_exchange_requests_on_offered_book_id"
    t.index ["requester_id"], name: "index_exchange_requests_on_requester_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "exchange_request_id", null: false
    t.datetime "read_at"
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_request_id"], name: "index_messages_on_exchange_request_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "exchange_request_id", null: false
    t.bigint "reviewee_id", null: false
    t.bigint "reviewer_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_request_id", "reviewer_id"], name: "index_reviews_on_exchange_request_id_and_reviewer_id", unique: true
    t.index ["exchange_request_id"], name: "index_reviews_on_exchange_request_id"
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.text "bio"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "suspended_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "books", "categories"
  add_foreign_key "books", "users"
  add_foreign_key "exchange_requests", "books"
  add_foreign_key "exchange_requests", "books", column: "offered_book_id"
  add_foreign_key "exchange_requests", "users", column: "requester_id"
  add_foreign_key "messages", "exchange_requests"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "reviews", "exchange_requests"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
end
