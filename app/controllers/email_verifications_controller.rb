class EmailVerificationsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    user = User.find_by_token_for(:email_verification, params[:token])

    if user.nil?
      return redirect_to articles_path, alert: "That verification link is invalid or has expired."
    end

    if user.email_verified?
      return redirect_to user_path(user), notice: "Your email has already been verified."
    end

    if user.update(email_verified_at: Time.current)
      redirect_to user_path(user), notice: "Email verified! Thanks."
    else
      redirect_to articles_path, alert: "We could not verify your email right now."
    end
  end
end
