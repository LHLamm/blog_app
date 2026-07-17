module Articles
  class PublishService
    class InvalidTransitionError < StandardError; end

    class Result
      attr_reader :article, :error

      def initialize(article:, error: nil)
        @article = article
        @error = error
      end

      def success?
        error.nil?
      end
    end

    def initialize(article:, actor: nil)
      @article = article
      @actor = actor
    end

    def call
      ActiveRecord::Base.transaction(requires_new: true) do
        change_status!
        increment_author_counter!
        write_log!
      end

      Result.new(article: article)
    rescue StandardError => e
      Rails.logger.error(
        "[Articles::PublishService] Publish thất bại cho article##{article.id}: #{e.class}: #{e.message}"
      )
      Result.new(article: article, error: e)
    end

    private

    attr_reader :article, :actor

    def change_status!
      if article.published?
        raise InvalidTransitionError, "Article##{article.id} đã ở trạng thái published"
      end

      article.update!(status: :published, published_at: Time.current)
    end

    def increment_author_counter!
      article.author.increment!(:published_articles_count)
    end

    def write_log!
      ActionLog.create!(
        loggable: article,
        user: actor,
        action: "publish",
        metadata: { status: article.status }
      )
    end
  end
end