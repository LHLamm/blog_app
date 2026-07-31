class ArticlesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  before_action :require_login, only: [ :new, :create, :edit, :update, :publish, :autosave, :destroy ]
  before_action :set_article, only: [ :show, :edit, :update, :publish, :autosave, :destroy ]

  def index
    authorize Article, :index?
    scoped_articles = policy_scope(Article)
    @articles = Articles::SearchQuery.new(scoped_articles).call(
      status: params[:status],
      author_id: params[:author_id],
      keyword: params[:keyword]
    )
    @authors =
      User.joins(:articles)
          .merge(scoped_articles)
          .distinct
          .order(:name)
  end

  def show
    authorize @article
  end

  def new
    @article = Article.new
    authorize @article
  end

  def create
    @article = current_user.articles.build(article_params)
    authorize @article

    if @article.save
      redirect_to article_path(@article), notice: "Article created as draft."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @article
  end

  def update
    authorize @article

    if @article.update(article_params)
      redirect_to article_path(@article), notice: "Article updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    authorize @article

    result = Articles::PublishService.new(article: @article, actor: current_user).call

    if result.success?
      ArticlePublishedNotifierJob.perform_later(result.article.id)
      redirect_to article_path(result.article), notice: "Article published."
    else
      redirect_to article_path(@article), alert: "Publish failed: #{result.error.message}"
    end
  end

  def autosave
    authorize @article, :update?

    if @article.update(autosave_params)
      render json: { status: "saved", saved_at: @article.updated_at.strftime("%H:%M:%S") }
    else
      render json: { status: "error", errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @article

    @article.destroy
    redirect_to dashboard_path, notice: "Article deleted."
  end

  private

  def set_article
    @article = Article.find_by(id: params[:id])
    redirect_to articles_path, alert: "Article not found." unless @article
  end

  def article_params
    params.require(:article).permit(:title, :body, :cover_image)
  end

  def autosave_params
    params.require(:article).permit(:title, :body)
  end
end
