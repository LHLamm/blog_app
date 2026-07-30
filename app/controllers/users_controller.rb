class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user

  def show
    authorize @user
  end

  private

  def set_user
    @user = User.includes(:user_profile).find_by(id: params[:id])
    redirect_to articles_path, alert: "User not found." unless @user
  end
end
