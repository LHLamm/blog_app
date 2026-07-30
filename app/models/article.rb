class Article < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :user_id, inverse_of: :articles
  has_many :action_logs, as: :loggable, dependent: :destroy, strict_loading: false
  has_one_attached :cover_image

  enum :status, { draft: 10, published: 20, archived: 30 },
       default: :draft, validate: true

  validates :title, presence: true
  validates :body, presence: true

  after_create_commit -> { broadcast_prepend_to :admin_dashboard, target: "articles_list", partial: "articles/article_row", locals: { article: self } }
  after_destroy_commit -> { broadcast_remove_to :admin_dashboard }
end
