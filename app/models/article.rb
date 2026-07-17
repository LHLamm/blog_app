class Article < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :user_id, inverse_of: :articles
  has_many :action_logs, as: :loggable, dependent: :destroy, strict_loading: false

  enum :status, { draft: "draft", published: "published", archived: "archived" },
       default: :draft, validate: true

  validates :title, presence: true
end
