class EmailVerificationsController < ApplicationController
  def show
    user = User.find_by_token_for(:email_verification, params[:token])

    if user
      user.update!(email_verified_at: Time.current)
      redirect_to articles_path, notice: "Email verified! Thanks."
    else
      redirect_to articles_path, alert: "That verification link is invalid or has expired."
    end
  end
end
