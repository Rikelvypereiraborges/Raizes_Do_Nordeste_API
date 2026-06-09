module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate!

      def index
        orders = Order.includes(:user, :unit, order_items: :product).order(created_at: :desc)
        orders = orders.where(user: current_user) if current_user.role == "cliente"
        orders = orders.by_canal(params[:canalPedido])
        orders = orders.by_status(params[:status])

        orders, meta = paginate(orders)
        render json: { data: orders.map { |order| order_json(order) }, meta: meta }
      end

      def show
        order = Order.find(params[:id])
        return unless can_access_order?(order)

        render json: { data: order_json(order) }
      end

      def create
        result = Orders::Creator.new(user: current_user, params: order_params).call
        render_service_result(result) do |order|
          audit!("orders.create", auditable: order, metadata: { canalPedido: order.canal_pedido })
          render json: { data: order_json(order) }, status: :created
        end
      end

      def update_status
        return unless authorize!(:atendente, :cozinha, :gerente, :admin)

        order = Order.find(params[:id])
        status = params[:status].to_s

        unless Order::STATUSES.include?(status)
          return render_error("status_invalido", "Status informado nao e permitido.", :unprocessable_entity)
        end

        if order.update(status: status, cancelled_at: status == "cancelado" ? Time.current : order.cancelled_at)
          audit!("orders.update_status", auditable: order, metadata: { status: status })
          render json: { data: order_json(order) }
        else
          render_model_errors(order)
        end
      end

      def cancel
        order = Order.find(params[:id])
        return unless can_access_order?(order)

        unless order.cancellable?
          return render_error("pedido_nao_cancelavel", "Pedido nao pode ser cancelado no status atual.", :unprocessable_entity)
        end

        order.update!(status: "cancelado", cancelled_at: Time.current)
        audit!("orders.cancel", auditable: order)
        render json: { data: order_json(order) }
      end

      private

      def order_params
        {
          unit_id: params[:unitId],
          canal_pedido: params[:canalPedido],
          items: Array(params[:itens]).map do |item|
            {
              product_id: item[:produtoId] || item["produtoId"],
              quantity: item[:quantidade] || item["quantidade"]
            }
          end
        }
      end

      def can_access_order?(order)
        return true unless current_user.role == "cliente"
        return true if order.user_id == current_user.id

        render_error("sem_permissao", "Usuario sem permissao para acessar este pedido.", :forbidden)
        false
      end
    end
  end
end
