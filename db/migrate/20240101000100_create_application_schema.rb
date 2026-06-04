class CreateApplicationSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "cliente"
      t.datetime :consent_at
      t.datetime :last_login_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_check_constraint :users, "role IN ('cliente', 'atendente', 'cozinha', 'gerente', 'admin')", name: "users_role_check"

    create_table :units do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :state, null: false, limit: 2
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_check_constraint :products, "price_cents > 0", name: "products_price_positive_check"

    create_table :stocks do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end
    add_index :stocks, [ :unit_id, :product_id ], unique: true
    add_check_constraint :stocks, "quantity >= 0", name: "stocks_quantity_non_negative_check"

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.string :canal_pedido, null: false
      t.string :status, null: false, default: "aguardando_pagamento"
      t.integer :total_cents, null: false, default: 0
      t.datetime :cancelled_at

      t.timestamps
    end
    add_index :orders, :canal_pedido
    add_index :orders, :status
    add_check_constraint :orders, "canal_pedido IN ('APP', 'TOTEM', 'BALCAO', 'PICKUP', 'WEB')", name: "orders_canal_pedido_check"
    add_check_constraint :orders, "status IN ('aguardando_pagamento', 'pago', 'preparando', 'pronto', 'entregue', 'cancelado', 'pagamento_negado')", name: "orders_status_check"
    add_check_constraint :orders, "total_cents >= 0", name: "orders_total_non_negative_check"

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.integer :total_cents, null: false

      t.timestamps
    end
    add_check_constraint :order_items, "quantity > 0", name: "order_items_quantity_positive_check"
    add_check_constraint :order_items, "unit_price_cents > 0", name: "order_items_unit_price_positive_check"
    add_check_constraint :order_items, "total_cents > 0", name: "order_items_total_positive_check"

    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status, null: false, default: "pendente"
      t.string :provider, null: false, default: "MOCK"
      t.integer :amount_cents, null: false
      t.json :request_payload, null: false, default: {}
      t.json :response_payload, null: false, default: {}

      t.timestamps
    end
    add_index :payments, :status
    add_check_constraint :payments, "status IN ('pendente', 'aprovado', 'negado')", name: "payments_status_check"
    add_check_constraint :payments, "amount_cents >= 0", name: "payments_amount_non_negative_check"

    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :auditable_type
      t.bigint :auditable_id
      t.json :metadata, null: false, default: {}
      t.string :ip_address

      t.timestamps
    end
    add_index :audit_logs, [ :auditable_type, :auditable_id ]
    add_index :audit_logs, :action
  end
end
