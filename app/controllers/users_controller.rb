class UsersController < ApplicationController
  def show
    @user = User.includes(:user_profile).find(params[:id])
  end
end
