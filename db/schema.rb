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

ActiveRecord::Schema[8.1].define(version: 2024_01_01_000100) do
  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.json "metadata", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "total_cents", null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.check_constraint "quantity > 0", name: "order_items_quantity_positive_check"
    t.check_constraint "total_cents > 0", name: "order_items_total_positive_check"
    t.check_constraint "unit_price_cents > 0", name: "order_items_unit_price_positive_check"
  end

  create_table "orders", force: :cascade do |t|
    t.string "canal_pedido", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.string "status", default: "aguardando_pagamento", null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "unit_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["canal_pedido"], name: "index_orders_on_canal_pedido"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["unit_id"], name: "index_orders_on_unit_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "canal_pedido IN ('APP', 'TOTEM', 'BALCAO', 'PICKUP', 'WEB')", name: "orders_canal_pedido_check"
    t.check_constraint "status IN ('aguardando_pagamento', 'pago', 'preparando', 'pronto', 'entregue', 'cancelado', 'pagamento_negado')", name: "orders_status_check"
    t.check_constraint "total_cents >= 0", name: "orders_total_non_negative_check"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.string "provider", default: "MOCK", null: false
    t.json "request_payload", default: {}, null: false
    t.json "response_payload", default: {}, null: false
    t.string "status", default: "pendente", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["status"], name: "index_payments_on_status"
    t.check_constraint "amount_cents >= 0", name: "payments_amount_non_negative_check"
    t.check_constraint "status IN ('pendente', 'aprovado', 'negado')", name: "payments_status_check"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "price_cents > 0", name: "products_price_positive_check"
  end

  create_table "stocks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 0, null: false
    t.integer "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stocks_on_product_id"
    t.index ["unit_id", "product_id"], name: "index_stocks_on_unit_id_and_product_id", unique: true
    t.index ["unit_id"], name: "index_stocks_on_unit_id"
    t.check_constraint "quantity >= 0", name: "stocks_quantity_non_negative_check"
  end

  create_table "units", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "state", limit: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "consent_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "last_login_at"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "cliente", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role IN ('cliente', 'atendente', 'cozinha', 'gerente', 'admin')", name: "users_role_check"
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "units"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "stocks", "products"
  add_foreign_key "stocks", "units"
end
