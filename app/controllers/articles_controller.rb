class ArticlesController < ApplicationController
  before_action :require_login, only: [ :new, :create, :edit, :update, :publish ]
  before_action :set_article, only: [ :show, :edit, :update, :publish ]

  def index
    @articles = Articles::SearchQuery.new(policy_scope(Article)).call(
      status: params[:status],
      author_id: params[:author_id],
      keyword: params[:keyword]
    )
    @authors = User.order(:name)
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
      redirect_to article_path(result.article), notice: "Article published."
    else
      redirect_to article_path(@article), alert: "Publish failed: #{result.error.message}"
    end
  end

  private

  def set_article
    @article = Article.includes(:author).find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body)
  end
end
