class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Rails 8 default - keep this if it's already in your file.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Please log in first."
  end

  def user_not_authorized
    redirect_to articles_path, alert: "You are not authorized to perform this action."
  end
end
