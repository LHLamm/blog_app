class PasswordResetsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :set_user_from_reset_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    UserMailer.password_reset(user).deliver_later if user

    redirect_to login_path, notice: "If that email exists, we've sent a reset link."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      redirect_to login_path, notice: "Password updated. Please log in."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_from_reset_token
    @user = User.find_by_token_for(:password_reset, params[:token])
    return if @user.present?

    redirect_to new_password_reset_path, alert: "That reset link is invalid or has expired."
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
