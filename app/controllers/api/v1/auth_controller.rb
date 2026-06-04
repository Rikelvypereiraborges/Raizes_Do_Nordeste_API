module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate!, only: :me

      def login
        user = User.find_by(email: params[:email].to_s.downcase)

        unless user&.authenticate(params[:password])
          return render_error("credenciais_invalidas", "E-mail ou senha invalidos.", :unauthorized)
        end

        user.update!(last_login_at: Time.current)
        AuditLog.create!(user: user, action: "auth.login", auditable_type: "User", auditable_id: user.id, metadata: { role: user.role }, ip_address: request.remote_ip)

        token = Rails.application.message_verifier(:auth_token).generate({
          "user_id" => user.id,
          "exp" => 24.hours.from_now.to_i
        })

        render json: { token: token, tokenType: "Bearer", expiresIn: 24.hours.to_i, user: user_json(user) }
      end

      def me
        render json: { user: user_json(current_user) }
      end
    end
  end
end
