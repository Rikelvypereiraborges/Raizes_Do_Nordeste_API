module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate!, only: [ :index, :show ]

      def index
        return unless authorize!(:gerente, :admin)

        render json: { data: User.order(:name).map { |user| user_json(user) } }
      end

      def show
        user = User.find(params[:id])
        return render_error("sem_permissao", "Usuario sem permissao para acessar este perfil.", :forbidden) unless current_user.admin? || current_user.gerente? || current_user.id == user.id

        render json: { data: user_json(user) }
      end

      def create
        user = User.new(user_params)
        user.role = "cliente" unless User::ROLES.include?(user.role)
        user.consent_at = Time.current if ActiveModel::Type::Boolean.new.cast(params[:acceptsPrivacy])

        if user.save
          render json: { data: user_json(user) }, status: :created
        else
          render_model_errors(user)
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation, :role)
      end
    end
  end
end
