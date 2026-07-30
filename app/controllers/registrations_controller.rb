class RegistrationsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :redirect_if_logged_in, only: %i[new create]

  def new
    @form = RegistrationForm.new
  end

  def create
    @form = RegistrationForm.new(registration_params)

    if @form.save
      log_in(@form.user)
      UserMailer.email_verification(@form.user).deliver_later
      redirect_to user_path(@form.user), notice: "Registration successful! Please check your email to verify your account."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_logged_in
    return unless logged_in?

    redirect_to articles_path, alert: "You are already logged in."
  end

  def registration_params
    params.require(:registration_form).permit(:name, :email, :password, :password_confirmation, :phone_number)
  end
end
