class User < ApplicationRecord
  ROLES = %w[cliente atendente cozinha gerente admin].freeze

  has_secure_password

  has_many :orders, dependent: :restrict_with_error
  has_many :audit_logs, dependent: :nullify

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def gerente?
    role == "gerente"
  end
end
