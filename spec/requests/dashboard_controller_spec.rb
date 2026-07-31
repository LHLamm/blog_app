require "rails_helper"

RSpec.describe "DashboardController", type: :request do
  let(:writer) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET /dashboard" do
    it "redirects guests to the login page" do
      get dashboard_path

      expect(response).to redirect_to(login_path)
    end

    it "denies a logged-in non-admin" do
      login_as(writer)

      get dashboard_path

      expect(response).to redirect_to(articles_path)
    end

    it "allows an admin and lists recent articles with authors preloaded" do
      article = create(:article, author: writer)
      login_as(admin)

      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(article.title)
    end
  end
end
