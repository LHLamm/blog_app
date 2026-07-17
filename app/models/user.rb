class User < ApplicationRecord
  has_many :articles, foreign_key: :user_id, inverse_of: :author, dependent: :destroy
  has_many :action_logs, dependent: :nullify

  validates :name, presence: true
end