module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :authenticate!

      def create
        order = Order.find(params[:order_id])
        return unless can_pay_order?(order)

        result = Payments::MockProcessor.new(order: order, params: payment_params).call
        render_service_result(result) do |payment|
          audit!("payments.mock", auditable: payment, metadata: { orderId: order.id, status: payment.status })
          render json: { data: payment_json(payment), order: order_json(order.reload) }, status: :created
        end
      end

      private

      def payment_params
        {
          card_token: params[:cardToken],
          force_status: params[:forceStatus],
          forma_pagamento: params[:formaPagamento] || "MOCK"
        }
      end

      def can_pay_order?(order)
        return true if current_user.admin? || current_user.gerente? || current_user.role == "atendente" || order.user_id == current_user.id

        render_error("sem_permissao", "Usuario sem permissao para pagar este pedido.", :forbidden)
        false
      end
    end
  end
end
