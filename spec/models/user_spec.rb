require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "không hợp lệ nếu thiếu name" do
      user = build(:user, name: nil)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "hợp lệ khi có name" do
      user = build(:user)

      expect(user).to be_valid
    end
  end

  describe "default values" do
    it "published_articles_count mặc định là 0" do
      user = create(:user)

      expect(user.published_articles_count).to eq(0)
    end
  end

  describe "associations" do
    let!(:user) { create(:user) }
    let!(:other_author) { create(:user) }
    let!(:article) { create(:article, author: user) }
    let!(:other_article) { create(:article, author: other_author) }

    # Log gắn với chính article của user -> khi user bị destroy, article này cũng bị destroy
    # (dependent: :destroy), kéo theo log này cũng bị destroy luôn (Article#action_logs dependent: :destroy).
    let!(:own_article_log) { create(:action_log, loggable: article, user: user, action_name: "publish") }

    # Log gắn với article của người khác (loggable không bị xoá cùng user) -> đây mới là ca test
    # đúng nghĩa cho User#action_logs dependent: :nullify, vì log này độc lập với vòng đời article.
    let!(:moderation_log) { create(:action_log, loggable: other_article, user: user, action_name: "flag") }

    it "destroy user thì destroy luôn các article của user đó (dependent: :destroy)" do
      expect { user.destroy }.to change(Article, :count).by(-1)
      expect(Article.exists?(article.id)).to be(false)
    end

    it "destroy user thì destroy luôn action_logs gắn với article bị xoá theo" do
      user.destroy

      expect(ActionLog.exists?(own_article_log.id)).to be(false)
    end

    it "destroy user thì set user_id = nil trên action_logs không phụ thuộc article bị xoá (dependent: :nullify)" do
      user.destroy

      expect(ActionLog.exists?(moderation_log.id)).to be(true)
      expect(ActionLog.find(moderation_log.id).user_id).to be_nil
    end
  end
end
