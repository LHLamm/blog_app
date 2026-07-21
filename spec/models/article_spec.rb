require "rails_helper"

RSpec.describe Article, type: :model do
  let!(:author) { create(:user) }

  describe "validations" do
    it "không hợp lệ nếu thiếu title" do
      article = build(:article, title: nil, author: author)

      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it "không hợp lệ nếu thiếu body" do
      article = build(:article, body: nil, author: author)

      expect(article).not_to be_valid
      expect(article.errors[:body]).to include("can't be blank")
    end

    it "hợp lệ khi có title, body và author" do
      article = build(:article, author: author)

      expect(article).to be_valid
    end
  end

  describe "enum :status" do
    it "mặc định là draft khi tạo mới" do
      article = create(:article, author: author)

      expect(article.status).to eq("draft")
      expect(article.draft?).to be(true)
    end

    it "cho phép chuyển sang published / archived" do
      article = create(:article, :published, author: author)
      expect(article.published?).to be(true)

      article.update!(status: :archived)
      expect(article.archived?).to be(true)
    end

    it "không hợp lệ (validation error) khi gán giá trị status không tồn tại, không raise ArgumentError" do
      article = create(:article, author: author)

      expect { article.status = "khong_ton_tai" }.not_to raise_error

      expect(article).not_to be_valid
      expect(article.errors[:status]).to be_present
    end
  end

  describe "associations" do
    it "belongs_to :author ánh xạ tới User qua user_id" do
      article = create(:article, author: author)

      expect(article.author).to eq(author)
      expect(article.user_id).to eq(author.id)
    end

    it "destroy article thì destroy luôn action_logs liên quan (dependent: :destroy)" do
      article = create(:article, author: author)
      log = create(:action_log, loggable: article, user: author)

      expect { article.destroy }.to change(ActionLog, :count).by(-1)
      expect(ActionLog.exists?(log.id)).to be(false)
    end
  end
end
