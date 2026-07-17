module Articles
  class SearchQuery
    EAGER_LOAD_ASSOCIATIONS = [:author].freeze

    def initialize(relation = Article.all)
      @relation = relation
    end

    def call(status: nil, author_id: nil, keyword: nil)
      relation
        .then { |rel| filter_by_status(rel, status) }
        .then { |rel| filter_by_author(rel, author_id) }
        .then { |rel| filter_by_keyword(rel, keyword) }
        .includes(*EAGER_LOAD_ASSOCIATIONS)
    end

    private

    attr_reader :relation

    def filter_by_status(rel, status)
      return rel if status.blank?
      return rel unless Article.statuses.key?(status.to_s)

      rel.where(status: status)
    end

    def filter_by_author(rel, author_id)
      return rel if author_id.blank?

      rel.where(user_id: author_id)
    end

    def filter_by_keyword(rel, keyword)
      return rel if keyword.blank?

      sanitized = ActiveRecord::Base.sanitize_sql_like(keyword)
      rel.where("articles.title LIKE :kw OR articles.body LIKE :kw", kw: "%#{sanitized}%")
    end
  end
end