class RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  attribute :phone_number, :string

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :phone_number, format: { with: /\A[0-9]{9,11}\z/ }, allow_blank: true

  attr_reader :user

  def save
    return false if invalid?

    normalized_email = email.to_s.strip.downcase

    ActiveRecord::Base.transaction do
      @user = User.create!(
        name: name,
        email: normalized_email,
        password: password,
        password_confirmation: password_confirmation
      )
      @user.create_user_profile!(phone_number: phone_number)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    merge_errors_from(e.record)
    false
  end

  def persisted?
    false
  end

  private

  def merge_errors_from(record)
    record.errors.each { |error| errors.add(error.attribute, error.message) }
  end
end
