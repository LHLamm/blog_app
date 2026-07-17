require "rails_helper"

RSpec.describe Article, type: :model do
  let!(:author) { User.create!(name: "Alice") }

  describe "validations" do
    it "không hợp lệ nếu thiếu title" do
      article = Article.new(title: nil, author: author)

      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it "hợp lệ khi có title và author" do
      article = Article.new(title: "Bài viết", author: author)

      expect(article).to be_valid
    end
  end

  describe "enum :status" do
    it "mặc định là draft khi tạo mới" do
      article = Article.create!(title: "Bài viết", author: author)

      expect(article.status).to eq("draft")
      expect(article.draft?).to be(true)
    end

    it "cho phép chuyển sang published / archived" do
      article = Article.create!(title: "Bài viết", author: author, status: :published)
      expect(article.published?).to be(true)

      article.update!(status: :archived)
      expect(article.archived?).to be(true)
    end

    it "không hợp lệ (validation error) khi gán giá trị status không tồn tại, không raise ArgumentError" do
      article = Article.create!(title: "Bài viết", author: author)

      expect { article.status = "khong_ton_tai" }.not_to raise_error

      expect(article).not_to be_valid
      expect(article.errors[:status]).to be_present
    end
  end

  describe "associations" do
    it "belongs_to :author ánh xạ tới User qua user_id" do
      article = Article.create!(title: "Bài viết", author: author)

      expect(article.author).to eq(author)
      expect(article.user_id).to eq(author.id)
    end

    it "destroy article thì destroy luôn action_logs liên quan (dependent: :destroy)" do
      article = Article.create!(title: "Bài viết", author: author)
      log = ActionLog.create!(loggable: article, user: author, action: "publish")

      expect { article.destroy }.to change(ActionLog, :count).by(-1)
      expect(ActionLog.exists?(log.id)).to be(false)
    end
  end
end
