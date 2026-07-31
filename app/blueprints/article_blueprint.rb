class ArticleBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :body, :status, :published_at, :created_at, :updated_at

  view :normal do
    field(:author_name) { |article, _| article.author&.name }

    field(:cover_image_url) do |article, _|
      next nil unless article.cover_image.attached?

      # Goi helper truc tiep qua module, khong extend vao class
      Rails.application.routes.url_helpers.rails_blob_path(
        article.cover_image,
        only_path: true
      )
    end
  end
end
