module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate!, except: [ :index, :show ]

      def index
        products = Product.where(active: true).order(:name)
        products = products.joins(:stocks).where(stocks: { unit_id: params[:unitId] }).distinct if params[:unitId].present?

        products, meta = paginate(products)
        render json: { data: products.map { |product| product_json(product) }, meta: meta }
      end

      def show
        render json: { data: product_json(Product.find(params[:id])) }
      end

      def create
        return unless authorize!(:gerente, :admin)

        product = Product.new(product_params)
        if product.save
          audit!("products.create", auditable: product)
          render json: { data: product_json(product) }, status: :created
        else
          render_model_errors(product)
        end
      end

      def update
        return unless authorize!(:gerente, :admin)

        product = Product.find(params[:id])
        if product.update(product_params)
          audit!("products.update", auditable: product)
          render json: { data: product_json(product) }
        else
          render_model_errors(product)
        end
      end

      private

      def product_params
        permitted = params.permit(:name, :description, :price_cents, :priceCents, :active)
        permitted[:price_cents] = permitted.delete(:priceCents) if permitted[:priceCents].present?
        permitted
      end
    end
  end
end
