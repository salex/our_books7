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

ActiveRecord::Schema[7.0].define(version: 2022_09_08_142557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "name"
    t.string "account_type"
    t.string "code"
    t.string "description"
    t.boolean "placeholder"
    t.boolean "contra"
    t.integer "parent_id"
    t.integer "level"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_accounts_on_book_id"
    t.index ["client_id"], name: "index_accounts_on_client_id"
  end

  create_table "bank_statements", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "book_id", null: false
    t.date "statement_date"
    t.integer "beginning_balance"
    t.integer "ending_balance"
    t.text "summary"
    t.date "reconciled_date"
    t.text "ofx_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bank_statements_on_book_id"
    t.index ["client_id"], name: "index_bank_statements_on_client_id"
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "client_id", null: false
    t.bigint "entry_id"
    t.date "post_date"
    t.integer "amount"
    t.string "fit_id"
    t.string "ck_numb"
    t.string "name"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bank_transactions_on_book_id"
    t.index ["client_id"], name: "index_bank_transactions_on_client_id"
    t.index ["entry_id"], name: "index_bank_transactions_on_entry_id"
    t.index ["fit_id"], name: "index_bank_transactions_on_fit_id"
  end

  create_table "books", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name"
    t.date "date_from"
    t.date "date_to"
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_books_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "acct"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "subdomain"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "setting"
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "numb"
    t.date "post_date"
    t.string "description"
    t.string "fit_id"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.index ["book_id"], name: "index_entries_on_book_id"
    t.index ["description"], name: "index_entries_on_description"
    t.index ["post_date"], name: "index_entries_on_post_date"
  end

  create_table "splits", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "entry_id", null: false
    t.string "memo"
    t.string "action"
    t.string "reconcile_state"
    t.date "reconcile_date"
    t.integer "amount"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.index ["account_id"], name: "index_splits_on_account_id"
    t.index ["entry_id"], name: "index_splits_on_entry_id"
  end

  create_table "stashes", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "book_id", null: false
    t.string "key"
    t.date "date"
    t.text "json"
    t.text "yaml"
    t.text "slim"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_stashes_on_book_id"
    t.index ["client_id"], name: "index_stashes_on_client_id"
    t.index ["key"], name: "index_stashes_on_key"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "email"
    t.string "username"
    t.string "full_name"
    t.string "roles"
    t.integer "default_book"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_users_on_client_id"
  end

  add_foreign_key "accounts", "books"
  add_foreign_key "accounts", "clients"
  add_foreign_key "bank_statements", "books"
  add_foreign_key "bank_statements", "clients"
  add_foreign_key "bank_transactions", "books"
  add_foreign_key "bank_transactions", "clients"
  add_foreign_key "bank_transactions", "entries"
  add_foreign_key "books", "clients"
  add_foreign_key "entries", "books"
  add_foreign_key "splits", "accounts"
  add_foreign_key "splits", "entries"
  add_foreign_key "stashes", "books"
  add_foreign_key "stashes", "clients"
  add_foreign_key "users", "clients"
end
