module Api
  module V1
    class ArticlesController < BaseController
      def index
        articles = Articles::SearchQuery.new(Article.published).call(
          author_id: params[:author_id],
          keyword: params[:keyword]
        )

        render json: ArticleBlueprint.render(articles, view: :normal)
      end
    end
  end
end
