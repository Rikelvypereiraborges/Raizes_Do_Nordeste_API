module Payments
  class MockProcessor
    def initialize(order:, params:)
      @order = order
      @params = params
    end

    def call
      unless @order.status == "aguardando_pagamento"
        return ServiceResult.new(record: nil, errors: [ "Pedido nao esta aguardando pagamento." ], status: "status_invalido")
      end

      approved = @params[:force_status].to_s.upcase != "NEGADO" && @params[:card_token].to_s.upcase != "NEGADO"
      response = {
        provider: "MOCK",
        approved: approved,
        authorizationCode: approved ? "MOCK-#{SecureRandom.hex(4).upcase}" : nil,
        message: approved ? "Pagamento aprovado." : "Pagamento negado pelo mock."
      }

      payment = nil
      ActiveRecord::Base.transaction do
        payment = @order.payments.create!(
          status: approved ? "aprovado" : "negado",
          provider: "MOCK",
          amount_cents: @order.total_cents,
          request_payload: @params,
          response_payload: response
        )
        @order.update!(status: approved ? "pago" : "pagamento_negado")
      end

      ServiceResult.new(record: payment, errors: [])
    end
  end
end
