require "rails_helper"

RSpec.describe Articles::SearchQuery do
  let!(:author_a) { User.create!(name: "Alice") }
  let!(:author_b) { User.create!(name: "Bob") }

  let!(:published_a1) do
    Article.create!(title: "Học Rails 8 từ đầu", body: "Nội dung A1", status: :published, author: author_a)
  end
  let!(:draft_b1) do
    Article.create!(title: "Ruby cơ bản", body: "Nội dung B1", status: :draft, author: author_b)
  end
  let!(:published_a2) do
    Article.create!(title: "Rails nâng cao: Query Object", body: "Nội dung A2", status: :published, author: author_a)
  end

  subject(:query) { described_class.new }

  describe "#call" do
    it "lọc theo status" do
      expect(query.call(status: "published")).to contain_exactly(published_a1, published_a2)
    end

    it "lọc theo author_id" do
      expect(query.call(author_id: author_a.id)).to contain_exactly(published_a1, published_a2)
    end

    it "lọc theo keyword trong title hoặc body" do
      expect(query.call(keyword: "Query Object")).to contain_exactly(published_a2)
    end

    it "kết hợp nhiều điều kiện lọc cùng lúc" do
      result = query.call(status: "published", author_id: author_a.id, keyword: "nâng cao")
      expect(result).to contain_exactly(published_a2)
    end

    it "bỏ qua giá trị status không hợp lệ thay vì raise lỗi" do
      expect { query.call(status: "khong_ton_tai") }.not_to raise_error
    end

    it "không phát sinh N+1 khi truy cập author (được bảo vệ bởi strict_loading)" do
      results = query.call(status: "published")

      expect {
        results.each { |article| article.author.name }
      }.not_to raise_error
    end
  end
end
