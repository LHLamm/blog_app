class ArticlePublishedNotifierJob < ApplicationJob
  queue_as :default

  def perform(article_id)
    article = Article.find_by(id: article_id)
    return if article.nil? || !article.published?

    UserMailer.article_published(article).deliver_later
  end
end
