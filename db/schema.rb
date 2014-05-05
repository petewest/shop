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

ActiveRecord::Schema.define(version: 20140505200456) do

  create_table "addresses", force: true do |t|
    t.string   "label"
    t.boolean  "default_billing"
    t.boolean  "default_delivery"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "addressable_type"
    t.integer  "user_id"
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "allocations", force: true do |t|
    t.integer  "line_item_id"
    t.integer  "stock_level_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
  end

  add_index "allocations", ["line_item_id", "stock_level_id"], name: "index_allocations_on_line_item_id_and_stock_level_id", unique: true, using: :btree
  add_index "allocations", ["line_item_id"], name: "index_allocations_on_line_item_id", using: :btree
  add_index "allocations", ["product_id"], name: "index_allocations_on_product_id", using: :btree
  add_index "allocations", ["stock_level_id"], name: "index_allocations_on_stock_level_id", using: :btree

  create_table "currencies", force: true do |t|
    t.string   "iso_code"
    t.string   "symbol"
    t.integer  "decimal_places"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["iso_code"], name: "index_currencies_on_iso_code", unique: true, using: :btree

  create_table "gift_cards", force: true do |t|
    t.integer  "buyer_id"
    t.integer  "redeemer_id"
    t.string   "token"
    t.integer  "start_value"
    t.integer  "current_value"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id"
  end

  add_index "gift_cards", ["buyer_id"], name: "index_gift_cards_on_buyer_id", using: :btree
  add_index "gift_cards", ["currency_id"], name: "index_gift_cards_on_currency_id", using: :btree
  add_index "gift_cards", ["redeemer_id"], name: "index_gift_cards_on_redeemer_id", using: :btree
  add_index "gift_cards", ["token"], name: "index_gift_cards_on_token", using: :btree

  create_table "images", force: true do |t|
    t.integer  "product_id"
    t.boolean  "main",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "caption"
  end

  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "line_items", force: true do |t|
    t.integer  "buyable_id"
    t.integer  "order_id"
    t.integer  "quantity",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id"
    t.integer  "unit_cost"
    t.string   "buyable_type", default: "Product", null: false
  end

  add_index "line_items", ["buyable_id"], name: "index_line_items_on_buyable_id", using: :btree
  add_index "line_items", ["buyable_type", "buyable_id"], name: "index_line_items_on_buyable_type_and_buyable_id", using: :btree
  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree

  create_table "order_addresses", force: true do |t|
    t.integer  "source_address_id"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_addresses", ["source_address_id"], name: "index_order_addresses_on_source_address_id", using: :btree

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
    t.integer  "billing_id"
    t.integer  "delivery_id"
    t.string   "stripe_charge_reference"
    t.datetime "cancelled_at"
    t.integer  "postage_cost_id"
    t.integer  "currency_id"
    t.integer  "unit_cost"
    t.integer  "postage_service_id"
    t.integer  "line_items_count",        default: 0, null: false
    t.integer  "gift_card_value",         default: 0
  end

  add_index "orders", ["billing_id"], name: "index_orders_on_billing_id", using: :btree
  add_index "orders", ["cart_token"], name: "index_orders_on_cart_token", unique: true, where: "((type)::text = 'Cart'::text)", using: :btree
  add_index "orders", ["currency_id"], name: "index_orders_on_currency_id", using: :btree
  add_index "orders", ["delivery_id"], name: "index_orders_on_delivery_id", using: :btree
  add_index "orders", ["postage_cost_id"], name: "index_orders_on_postage_cost_id", using: :btree
  add_index "orders", ["postage_service_id"], name: "index_orders_on_postage_service_id", using: :btree
  add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "postage_costs", force: true do |t|
    t.float    "from_weight"
    t.float    "to_weight"
    t.integer  "unit_cost"
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "postage_service_id"
  end

  add_index "postage_costs", ["currency_id"], name: "index_postage_costs_on_currency_id", using: :btree
  add_index "postage_costs", ["postage_service_id"], name: "index_postage_costs_on_postage_service_id", using: :btree

  create_table "postage_services", force: true do |t|
    t.string   "name"
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_cost"
    t.integer  "currency_id"
    t.float    "weight"
    t.string   "type"
    t.integer  "master_product_id"
  end

  add_index "products", ["master_product_id"], name: "index_products_on_master_product_id", using: :btree
  add_index "products", ["seller_id"], name: "index_products_on_seller_id", using: :btree
  add_index "products", ["type"], name: "index_products_on_type", using: :btree

  create_table "redemptions", force: true do |t|
    t.integer  "order_id"
    t.integer  "gift_card_id"
    t.integer  "currency_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redemptions", ["currency_id"], name: "index_redemptions_on_currency_id", using: :btree
  add_index "redemptions", ["gift_card_id"], name: "index_redemptions_on_gift_card_id", using: :btree
  add_index "redemptions", ["order_id"], name: "index_redemptions_on_order_id", using: :btree

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
    t.boolean  "bcc_on_email",    default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
