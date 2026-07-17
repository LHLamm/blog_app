class User < ApplicationRecord
  has_many :articles, foreign_key: :user_id, inverse_of: :author, dependent: :destroy, strict_loading: false
  has_many :action_logs, dependent: :nullify, strict_loading: false

  validates :name, presence: true
end