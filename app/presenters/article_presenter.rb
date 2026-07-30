class ArticlePresenter < SimpleDelegator
  def initialize(article, current_user:, view_context:)
    super(article)
    @current_user = current_user
    @view_context = view_context
  end

  def formatted_created_at
    I18n.l(created_at, format: :short)
  rescue I18n::ArgumentError, ArgumentError
    created_at.strftime("%b %d, %Y")
  end

  def author_display
    if author == @current_user
      @view_context.link_to(author.name, @view_context.user_path(author))
    else
      author.name
    end
  end
end
