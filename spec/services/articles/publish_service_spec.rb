require "rails_helper"

RSpec.describe Articles::PublishService do
  let!(:author) { create(:user) }
  let!(:article) { create(:article, title: "Bài viết test", status: :draft, author: author) }

  describe "#call" do
    context "khi cả 3 bước đều thành công" do
      it "đổi status bài viết sang published" do
        expect { described_class.new(article: article).call }
          .to change { article.reload.status }.from("draft").to("published")
      end

      it "tăng published_articles_count của tác giả thêm 1" do
        expect { described_class.new(article: article).call }
          .to change { author.reload.published_articles_count }.by(1)
      end

      it "tạo 1 ActionLog polymorphic trỏ về article" do
        expect { described_class.new(article: article).call }
          .to change(ActionLog, :count).by(1)

        log = ActionLog.strict_loading(false).last
        expect(log.loggable).to eq(article)
        expect(log.action_name).to eq("publish")
      end

      it "trả về Result#success? = true" do
        result = described_class.new(article: article).call
        expect(result.success?).to be(true)
      end
    end

    context "khi bước ghi log thất bại giữa chừng" do
      before do
        allow(ActionLog).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(ActionLog.new))
      end

      it "rollback: status KHÔNG đổi" do
        expect { described_class.new(article: article).call }
          .not_to change { article.reload.status }
      end

      it "rollback: counter KHÔNG tăng" do
        expect { described_class.new(article: article).call }
          .not_to change { author.reload.published_articles_count }
      end

      it "rollback: không log nào được tạo" do
        expect { described_class.new(article: article).call }
          .not_to change(ActionLog, :count)
      end

      it "trả về Result#success? = false kèm error gốc" do
        result = described_class.new(article: article).call
        expect(result.success?).to be(false)
        expect(result.error).to be_a(ActiveRecord::RecordInvalid)
      end
    end

    context "khi article đã published từ trước" do
      let!(:article) { create(:article, :published, title: "Bài viết test", author: author) }

      it "raise InvalidTransitionError ngay bước 1, counter không đổi" do
        result = nil

        expect { result = described_class.new(article: article).call }
          .not_to change { author.reload.published_articles_count }

        expect(result.success?).to be(false)
        expect(result.error).to be_a(Articles::PublishService::InvalidTransitionError)
      end
    end
  end
end
