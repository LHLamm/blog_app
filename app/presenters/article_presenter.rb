class ArticlePresenter < SimpleDelegator
  def formatted_created_at
    I18n.l(created_at, format: :short)
  rescue I18n::ArgumentError, ArgumentError
    created_at.strftime("%b %d, %Y")
  end
end
