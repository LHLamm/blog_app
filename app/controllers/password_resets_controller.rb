class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    UserMailer.password_reset(user).deliver_later if user

    redirect_to login_path, notice: "If that email exists, we've sent a reset link."
  end

  def edit
    @user = User.find_by_token_for(:password_reset, params[:token])
    redirect_to new_password_reset_path, alert: "That reset link is invalid or has expired." unless @user
  end

  def update
    @user = User.find_by_token_for(:password_reset, params[:token])
    return redirect_to new_password_reset_path, alert: "That reset link is invalid or has expired." unless @user

    if @user.update(password_params)
      redirect_to login_path, notice: "Password updated. Please log in."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
