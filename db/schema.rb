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

ActiveRecord::Schema.define(version: 2018_12_12_212903) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_subjects", id: :serial, force: :cascade do |t|
    t.integer "book_id"
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_subjects_on_book_id"
    t.index ["subject_id"], name: "index_book_subjects_on_subject_id"
  end

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "books", id: :serial, force: :cascade do |t|
    t.string "marcxml"
    t.string "digital_cico_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["digital_cico_number"], name: "index_books_on_digital_cico_number", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "entry_id"
    t.string "text"
    t.datetime "timestamp"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_comments_on_entry_id"
  end

  create_table "contributing_libraries", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "creator_roles", id: :serial, force: :cascade do |t|
    t.integer "book_id"
    t.integer "creator_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_creator_roles_on_book_id"
    t.index ["creator_id"], name: "index_creator_roles_on_creator_id"
    t.index ["role_id"], name: "index_creator_roles_on_role_id"
  end

  create_table "creators", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", id: :serial, force: :cascade do |t|
    t.string "section_head"
    t.string "section_display"
    t.string "section_number"
    t.string "n_value"
    t.string "entry_id"
    t.text "tei"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_entries_on_entry_id"
    t.index ["n_value"], name: "index_entries_on_n_value"
  end

  create_table "entry_books", id: :serial, force: :cascade do |t|
    t.integer "book_id"
    t.integer "entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_entry_books_on_book_id"
    t.index ["entry_id"], name: "index_entry_books_on_entry_id"
  end

  create_table "news_items", force: :cascade do |t|
    t.string "body"
    t.datetime "timestamp"
    t.string "title"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.text "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "uri"
    t.string "genre"
    t.string "geographic"
    t.string "name"
    t.string "temporal"
    t.string "topic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "contributing_library_id"
    t.integer "book_id"
    t.string "owner_call_number"
    t.string "owner_system_number"
    t.string "other_number"
    t.string "label"
    t.string "version_edition_statement"
    t.string "version_publication_statement"
    t.string "version_publication_date"
    t.string "additional_responsibility"
    t.string "provenance"
    t.string "physical_characteristics"
    t.string "rights"
    t.boolean "based_on_original"
    t.string "manifest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_versions_on_book_id"
    t.index ["contributing_library_id"], name: "index_versions_on_contributing_library_id"
  end

  add_foreign_key "book_subjects", "books"
  add_foreign_key "book_subjects", "subjects"
  add_foreign_key "comments", "entries"
  add_foreign_key "creator_roles", "books"
  add_foreign_key "creator_roles", "creators"
  add_foreign_key "creator_roles", "roles"
  add_foreign_key "entry_books", "books"
  add_foreign_key "entry_books", "entries"
  add_foreign_key "versions", "books"
  add_foreign_key "versions", "contributing_libraries"
end
