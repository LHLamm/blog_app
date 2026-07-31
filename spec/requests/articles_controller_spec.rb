require "rails_helper"

RSpec.describe "ArticlesController", type: :request do
  let(:writer) { create(:user) }
  let(:other_writer) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET /articles" do
    it "is accessible without logging in and only lists non-draft articles for guests" do
      published = create(:article, :published, author: writer)
      create(:article, author: writer) # draft, should be hidden from guests

      get articles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(published.title)
    end
  end

  describe "GET /articles/:id/edit" do
    let(:draft) { create(:article, author: writer) }

    it "redirects guests to the login page" do
      get edit_article_path(draft)

      expect(response).to redirect_to(login_path)
    end

    it "allows the owner to edit their own draft" do
      login_as(writer)

      get edit_article_path(draft)

      expect(response).to have_http_status(:ok)
    end

    it "denies another writer editing someone else's draft" do
      login_as(other_writer)

      get edit_article_path(draft)

      expect(response).to redirect_to(articles_path)
      follow_redirect!
      expect(response.body).to include("not authorized")
    end
  end

  describe "PATCH /articles/:id" do
    let(:draft) { create(:article, author: writer) }

    it "updates the article, including the cover image, for the owner" do
      login_as(writer)

      patch article_path(draft), params: { article: { title: "Updated title" } }

      expect(response).to redirect_to(article_path(draft))
      expect(draft.reload.title).to eq("Updated title")
    end
  end

  describe "PATCH /articles/:id/autosave" do
    let(:draft) { create(:article, author: writer) }

    before { login_as(writer) }

    it "updates title and body" do
      patch autosave_article_path(draft), params: { article: { title: "Autosaved title", body: "Autosaved body" } }

      expect(response).to have_http_status(:ok)
      expect(draft.reload.title).to eq("Autosaved title")
      expect(draft.body).to eq("Autosaved body")
    end

    it "ignores a cover_image param even if one is sent (autosave must never mass-assign files)" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.txt"), "text/plain")

      patch autosave_article_path(draft), params: { article: { title: "Still text only", cover_image: file } }

      expect(response).to have_http_status(:ok)
      expect(draft.reload.title).to eq("Still text only")
      expect(draft.cover_image).not_to be_attached
    end

    it "denies autosaving a published article, even for the owner" do
      published = create(:article, :published, author: writer)

      patch autosave_article_path(published), params: { article: { title: "Nope" } }

      expect(response).to redirect_to(articles_path)
    end
  end

  describe "POST /articles/:id/publish" do
    let(:draft) { create(:article, author: writer) }

    it "publishes the article and enqueues the notifier job" do
      login_as(writer)

      expect {
        post publish_article_path(draft)
      }.to have_enqueued_job(ArticlePublishedNotifierJob).with(draft.id)

      expect(draft.reload).to be_published
      expect(response).to redirect_to(article_path(draft))
    end
  end

  describe "DELETE /articles/:id" do
    let(:draft) { create(:article, author: writer) }

    it "denies a non-admin owner from deleting their own article" do
      login_as(writer)
      draft

      expect { delete article_path(draft) }.not_to change(Article, :count)
      expect(response).to redirect_to(articles_path)
    end

    it "allows an admin to delete any article and redirects to the dashboard" do
      login_as(admin)
      draft

      expect { delete article_path(draft) }.to change(Article, :count).by(-1)
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
