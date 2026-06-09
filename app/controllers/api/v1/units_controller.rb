module Api
  module V1
    class UnitsController < ApplicationController
      before_action :authenticate!, except: [ :index, :show ]

      def index
        units, meta = paginate(Unit.order(:name))
        render json: { data: units.map { |unit| unit_json(unit) }, meta: meta }
      end

      def show
        render json: { data: unit_json(Unit.find(params[:id])) }
      end

      def create
        return unless authorize!(:gerente, :admin)

        unit = Unit.new(unit_params)
        if unit.save
          audit!("units.create", auditable: unit)
          render json: { data: unit_json(unit) }, status: :created
        else
          render_model_errors(unit)
        end
      end

      private

      def unit_params
        params.permit(:name, :city, :state, :active)
      end
    end
  end
end
