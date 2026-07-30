class ArticleBlueprint < Blueprinter::Base
  extend Rails.application.routes.url_helpers

  identifier :id
  fields :title, :body, :status, :published_at, :created_at, :updated_at

  view :normal do
    field(:author_name) { |article, _| article.author&.name }
    field(:cover_image_url) { |article, _| article.cover_image.attached? ? rails_blob_path(article.cover_image, only_path: true) : nil }
  end
end
