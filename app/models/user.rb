class User < ApplicationRecord
  has_secure_password

  has_many :articles, foreign_key: :user_id, inverse_of: :author, dependent: :destroy, strict_loading: false
  has_many :action_logs, dependent: :nullify, strict_loading: false
  has_one :user_profile, dependent: :destroy, inverse_of: :user, strict_loading: false

  enum :role, { writer: 0, admin: 1 }, default: :writer

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt
  end

  generates_token_for :email_verification, expires_in: 1.day do
    email
  end

  validates :name, presence: true
  validates :email, presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  def email_verified?
    email_verified_at.present?
  end

  private

  def password_salt
    password_digest&.first(29)
  end
end
