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

ActiveRecord::Schema.define(version: 20140409123645) do

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.string   "label"
    t.boolean  "default_billing"
    t.boolean  "default_delivery"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["user_id", "default_billing"], name: "index_addresses_on_user_id_and_default_billing", using: :btree
  add_index "addresses", ["user_id", "default_delivery"], name: "index_addresses_on_user_id_and_default_delivery", using: :btree
  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "allocations", force: true do |t|
    t.integer  "line_item_id"
    t.integer  "stock_level_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "allocations", ["line_item_id", "stock_level_id"], name: "index_allocations_on_line_item_id_and_stock_level_id", unique: true, using: :btree
  add_index "allocations", ["line_item_id"], name: "index_allocations_on_line_item_id", using: :btree
  add_index "allocations", ["stock_level_id"], name: "index_allocations_on_stock_level_id", using: :btree

  create_table "currencies", force: true do |t|
    t.string   "iso_code"
    t.string   "symbol"
    t.integer  "decimal_places"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["iso_code"], name: "index_currencies_on_iso_code", unique: true, using: :btree

  create_table "images", force: true do |t|
    t.integer  "product_id"
    t.boolean  "main",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "line_items", force: true do |t|
    t.integer  "product_id"
    t.integer  "order_id"
    t.integer  "quantity",    default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id"
    t.integer  "unit_cost"
  end

  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "placed_at"
    t.datetime "paid_at"
    t.datetime "dispatched_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "cart_token"
  end

  add_index "orders", ["cart_token"], name: "index_orders_on_cart_token", unique: true, where: "((type)::text = 'Cart'::text)", using: :btree
  add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_cost"
    t.integer  "currency_id"
    t.float    "weight"
  end

  add_index "products", ["seller_id"], name: "index_products_on_seller_id", using: :btree

  create_table "sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "ip_addr"
    t.string   "remember_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["remember_token"], name: "index_sessions_on_remember_token", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "stock_levels", force: true do |t|
    t.integer  "product_id"
    t.datetime "due_at"
    t.integer  "start_quantity"
    t.integer  "current_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.boolean  "allow_preorder",   default: false
  end

  add_index "stock_levels", ["product_id"], name: "index_stock_levels_on_product_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "address"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
