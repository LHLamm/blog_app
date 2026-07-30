class DashboardController < ApplicationController
  skip_after_action :verify_authorized

  before_action :require_login
  before_action :require_admin

  def index
    @articles = Article.includes(:author).order(created_at: :desc).limit(20)
  end

  private

  def require_admin
    return if current_user.admin?

    redirect_to articles_path, alert: "Dashboard is admin-only."
  end
end
