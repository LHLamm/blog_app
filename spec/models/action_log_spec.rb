require "rails_helper"

RSpec.describe ActionLog, type: :model do
  let!(:author) { User.create!(name: "Alice") }
  let!(:article) { Article.create!(title: "Bài viết", body: "...", author: author) }

  describe "validations" do
    it "không hợp lệ nếu thiếu action_name" do
      log = ActionLog.new(loggable: article, user: author, action_name: nil)

      expect(log).not_to be_valid
      expect(log.errors[:action_name]).to include("can't be blank")
    end
  end

  describe "belongs_to :user, optional: true" do
    it "hợp lệ ngay cả khi không có user (log hệ thống)" do
      log = ActionLog.new(loggable: article, user: nil, action_name: "auto_archive")

      expect(log).to be_valid
    end
  end

  describe "belongs_to :loggable, polymorphic: true" do
    it "gắn được vào Article và lưu đúng loggable_type/loggable_id" do
      log = ActionLog.create!(loggable: article, user: author, action_name: "publish")

      expect(log.loggable_type).to eq("Article")
      expect(log.loggable_id).to eq(article.id)
      expect(log.loggable).to eq(article)
    end

    it "không hợp lệ nếu thiếu loggable" do
      log = ActionLog.new(loggable: nil, user: author, action_name: "publish")

      expect(log).not_to be_valid
    end
  end
end
