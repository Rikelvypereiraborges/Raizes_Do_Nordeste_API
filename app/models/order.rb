class Order < ApplicationRecord
  CANAIS = %w[APP TOTEM BALCAO PICKUP WEB].freeze
  STATUSES = %w[aguardando_pagamento pago preparando pronto entregue cancelado pagamento_negado].freeze

  belongs_to :user
  belongs_to :unit
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :canal_pedido, inclusion: { in: CANAIS }
  validates :status, inclusion: { in: STATUSES }
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_canal, ->(canal) { where(canal_pedido: canal) if canal.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  def cancellable?
    %w[aguardando_pagamento pago preparando].include?(status)
  end
end
