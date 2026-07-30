class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Rails 8 default - keep this if it's already in your file.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :verify_authorized

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]).tap do |user|
      session[:user_id] = nil if session[:user_id].present? && user.nil?
    end
  end

  def logged_in?
    current_user.present?
  end

  def log_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def require_login
    return if logged_in?

    store_location
    redirect_to login_path, alert: "Please log in first."
  end

  def store_location
    session[:return_to] = request.fullpath if request.get? || request.head?
  end

  def return_location
    session.delete(:return_to) || articles_path
  end

  def user_not_authorized
    redirect_to articles_path, alert: "You are not authorized to perform this action."
  end
end
