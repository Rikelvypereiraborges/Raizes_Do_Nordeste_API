module Api
  module V1
    class OpenapiController < ApplicationController
      def show
        render json: OpenapiDocument.build
      end
    end
  end
end
