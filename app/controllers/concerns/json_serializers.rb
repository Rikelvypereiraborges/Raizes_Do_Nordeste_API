module JsonSerializers
  extend ActiveSupport::Concern

  private

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      consentAt: user.consent_at&.iso8601,
      createdAt: user.created_at.iso8601
    }
  end

  def unit_json(unit)
    {
      id: unit.id,
      name: unit.name,
      city: unit.city,
      state: unit.state,
      active: unit.active
    }
  end

  def product_json(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      priceCents: product.price_cents,
      active: product.active
    }
  end

  def stock_json(stock)
    {
      id: stock.id,
      unit: unit_json(stock.unit),
      product: product_json(stock.product),
      quantity: stock.quantity
    }
  end

  def order_json(order)
    {
      id: order.id,
      cliente: user_json(order.user),
      unidade: unit_json(order.unit),
      canalPedido: order.canal_pedido,
      status: order.status,
      totalCents: order.total_cents,
      itens: order.order_items.includes(:product).map { |item| order_item_json(item) },
      pagamentos: order.payments.order(created_at: :desc).map { |payment| payment_json(payment) },
      createdAt: order.created_at.iso8601
    }
  end

  def order_item_json(item)
    {
      id: item.id,
      produto: product_json(item.product),
      quantity: item.quantity,
      unitPriceCents: item.unit_price_cents,
      totalCents: item.total_cents
    }
  end

  def payment_json(payment)
    {
      id: payment.id,
      orderId: payment.order_id,
      status: payment.status,
      provider: payment.provider,
      amountCents: payment.amount_cents,
      response: payment.response_payload,
      createdAt: payment.created_at.iso8601
    }
  end
end
