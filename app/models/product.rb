class Product < ApplicationRecord
  has_many :stocks, dependent: :destroy
  has_many :units, through: :stocks
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end
