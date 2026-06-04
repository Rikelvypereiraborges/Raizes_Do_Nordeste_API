class Payment < ApplicationRecord
  STATUSES = %w[pendente aprovado negado].freeze

  belongs_to :order

  validates :status, inclusion: { in: STATUSES }
  validates :provider, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
