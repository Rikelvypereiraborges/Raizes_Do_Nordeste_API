module Orders
  class Creator
    def initialize(user:, params:)
      @user = user
      @params = params
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        validate!
        raise ActiveRecord::Rollback if @errors.any?

        order = Order.create!(
          user: @user,
          unit: @unit,
          canal_pedido: @canal_pedido,
          status: "aguardando_pagamento",
          total_cents: 0
        )

        total_cents = create_items!(order)
        order.update!(total_cents: total_cents)
        return ServiceResult.new(record: order.reload, errors: [])
      end

      ServiceResult.new(record: nil, errors: @errors, status: "pedido_invalido")
    end

    private

    def validate!
      @unit = Unit.find_by(id: @params[:unit_id])
      @canal_pedido = @params[:canal_pedido].presence
      @items = Array(@params[:items])

      @errors << "Unidade nao encontrada." unless @unit
      @errors << "canalPedido deve ser informado." if @canal_pedido.blank?
      @errors << "canalPedido invalido." if @canal_pedido.present? && !Order::CANAIS.include?(@canal_pedido)
      @errors << "Informe ao menos um item." if @items.empty?
    end

    def create_items!(order)
      total_cents = 0

      @items.each do |item|
        product = Product.find_by(id: item[:product_id])
        quantity = item[:quantity].to_i
        stock = product && Stock.lock.find_by(unit: @unit, product: product)

        if product.blank? || !product.active?
          @errors << "Produto #{item[:product_id]} indisponivel."
          next
        end

        if quantity <= 0
          @errors << "Quantidade do produto #{product.id} deve ser maior que zero."
          next
        end

        if stock.blank? || stock.quantity < quantity
          @errors << "Estoque insuficiente para #{product.name}."
          next
        end

        item_total = product.price_cents * quantity
        stock.update!(quantity: stock.quantity - quantity)
        order.order_items.create!(
          product: product,
          quantity: quantity,
          unit_price_cents: product.price_cents,
          total_cents: item_total
        )
        total_cents += item_total
      end

      raise ActiveRecord::Rollback if @errors.any?

      total_cents
    end
  end
end
