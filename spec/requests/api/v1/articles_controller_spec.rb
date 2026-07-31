require "rails_helper"

RSpec.describe "Api::V1::ArticlesController", type: :request do
  let(:writer) { create(:user) }

  before do
    allow_any_instance_of(Api::V1::BaseController)
      .to receive(:expected_bearer_token).and_return("test-token")
  end

  describe "GET /api/v1/articles" do
    it "rejects the request when no Authorization header is sent" do
      get api_v1_articles_path

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a non-bearer scheme" do
      get api_v1_articles_path, headers: { "Authorization" => "Basic test-token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an incorrect token" do
      get api_v1_articles_path, headers: { "Authorization" => "Bearer wrong-token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only published articles for a valid token" do
      published = create(:article, :published, author: writer)
      create(:article, author: writer) # draft, must not be exposed via the API

      get api_v1_articles_path, headers: { "Authorization" => "Bearer test-token" }

      expect(response).to have_http_status(:ok)
      titles = JSON.parse(response.body).map { |a| a["title"] }
      expect(titles).to contain_exactly(published.title)
    end
  end
end
