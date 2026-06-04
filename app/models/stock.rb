class Stock < ApplicationRecord
  belongs_to :unit
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :unit_id }
end
