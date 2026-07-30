class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @token = user.generate_token_for(:password_reset)

    mail(to: @user.email, subject: "Reset your password")
  end

  def email_verification(user)
    @user = user
    @token = user.generate_token_for(:email_verification)

    mail(to: @user.email, subject: "Confirm your email")
  end
end
