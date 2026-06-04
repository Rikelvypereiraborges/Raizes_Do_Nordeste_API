class Unit < ApplicationRecord
  has_many :stocks, dependent: :destroy
  has_many :products, through: :stocks
  has_many :orders, dependent: :restrict_with_error

  validates :name, :city, :state, presence: true
  validates :state, length: { is: 2 }
end
