module Stocks
  class Mover
    def initialize(params:)
      @params = params
    end

    def call
      unit = Unit.find_by(id: @params[:unit_id])
      product = Product.find_by(id: @params[:product_id])
      kind = @params[:kind].to_s
      quantity = @params[:quantity].to_i

      return failure("Unidade nao encontrada.") unless unit
      return failure("Produto nao encontrado.") unless product
      return failure("Tipo deve ser entrada ou saida.") unless %w[entrada saida].include?(kind)
      return failure("Quantidade deve ser maior que zero.") unless quantity.positive?

      stock = Stock.find_or_initialize_by(unit: unit, product: product)
      stock.quantity ||= 0
      next_quantity = kind == "entrada" ? stock.quantity + quantity : stock.quantity - quantity
      return failure("Estoque insuficiente para saida.") if next_quantity.negative?

      stock.update!(quantity: next_quantity)
      ServiceResult.new(record: stock, errors: [])
    end

    private

    def failure(message)
      ServiceResult.new(record: nil, errors: [ message ], status: "movimentacao_invalida")
    end
  end
end
