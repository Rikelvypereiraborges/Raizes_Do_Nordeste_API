class ApplicationController < ActionController::API
  include JsonSerializers

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  attr_reader :current_user

  private

  def authenticate!
    token = request.authorization.to_s.split.last
    payload = Rails.application.message_verifier(:auth_token).verified(token)

    unless payload.present? && payload["exp"].to_i > Time.current.to_i
      return render_error("nao_autenticado", "Token ausente, invalido ou expirado.", :unauthorized)
    end

    @current_user = User.find(payload["user_id"])
  end

  def authorize!(*roles)
    return true if current_user&.admin? || roles.map(&:to_s).include?(current_user&.role)

    render_error("sem_permissao", "Usuario sem permissao para executar esta acao.", :forbidden)
    false
  end

  def render_error(code, message, status, details: nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details.present?
    render json: body, status: status
  end

  def render_model_errors(record, status = :unprocessable_entity)
    render_error("validacao", "Dados invalidos.", status, details: record.errors.to_hash(true))
  end

  def render_service_result(result)
    return yield result.record if result.success?

    render_error(result.status || "erro_regra_negocio", result.errors.to_sentence, :unprocessable_entity)
  end

  def paginate(scope)
    page = params[:page].to_i
    limit = params[:limit].to_i
    page = 1 if page < 1
    limit = 20 if limit < 1
    limit = 100 if limit > 100

    [
      scope.offset((page - 1) * limit).limit(limit),
      { page: page, limit: limit, total: scope.count }
    ]
  end

  def audit!(action, auditable: nil, metadata: {})
    AuditLog.create!(
      user: current_user,
      action: action,
      auditable_type: auditable&.class&.name,
      auditable_id: auditable&.id,
      metadata: metadata,
      ip_address: request.remote_ip
    )
  end

  def render_not_found
    render_error("nao_encontrado", "Recurso nao encontrado.", :not_found)
  end

  def render_parameter_missing(error)
    render_error("parametro_obrigatorio", error.message, :bad_request)
  end
end
