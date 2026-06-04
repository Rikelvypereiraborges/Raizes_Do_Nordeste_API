module Api
  module V1
    class StocksController < ApplicationController
      before_action :authenticate!

      def index
        stocks = Stock.includes(:unit, :product).order(:unit_id, :product_id)
        stocks = stocks.where(unit_id: params[:unitId]) if params[:unitId].present?
        stocks = stocks.where(product_id: params[:productId]) if params[:productId].present?

        render json: { data: stocks.map { |stock| stock_json(stock) } }
      end

      def move
        return unless authorize!(:gerente, :admin)

        result = Stocks::Mover.new(params: movement_params).call
        render_service_result(result) do |stock|
          audit!("stocks.move", auditable: stock, metadata: movement_params.to_h)
          render json: { data: stock_json(stock) }
        end
      end

      private

      def movement_params
        {
          unit_id: params[:unitId],
          product_id: params[:productId],
          kind: params[:kind],
          quantity: params[:quantity]
        }
      end
    end
  end
end
