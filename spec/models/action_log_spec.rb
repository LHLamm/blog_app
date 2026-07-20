require "rails_helper"

RSpec.describe ActionLog, type: :model do
  let!(:author) { create(:user) }
  let!(:article) { create(:article, author: author) }

  describe "validations" do
    it "không hợp lệ nếu thiếu action_name" do
      log = build(:action_log, loggable: article, user: author, action_name: nil)

      expect(log).not_to be_valid
      expect(log.errors[:action_name]).to include("can't be blank")
    end
  end

  describe "system-generated logs" do
    it "hợp lệ ngay cả khi không có user (log hệ thống)" do
      log = build(:action_log, loggable: article, user: nil, action_name: "auto_archive")

      expect(log).to be_valid
    end
  end

  describe "belongs_to :loggable, polymorphic: true" do
    it "gắn được vào Article và lưu đúng loggable_type/loggable_id" do
      log = create(:action_log, loggable: article, user: author, action_name: "publish")

      expect(log.loggable_type).to eq("Article")
      expect(log.loggable_id).to eq(article.id)
      expect(log.loggable).to eq(article)
    end

    it "không hợp lệ nếu thiếu loggable" do
      log = build(:action_log, loggable: nil, user: author, action_name: "publish")

      expect(log).not_to be_valid
    end
  end
end
