class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile

  validates :phone_number, format: { with: /\A[0-9]{9,11}\z/ }, allow_blank: true
end
