class RegistrationsController < ApplicationController
  def new
    @form = RegistrationForm.new
  end

  def create
    @form = RegistrationForm.new(registration_params)

    if @form.save
      session[:user_id] = @form.user.id
      UserMailer.email_verification(@form.user).deliver_later
      redirect_to user_path(@form.user), notice: "Registration successful! Please check your email to verify your account."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:registration_form).permit(:name, :email, :password, :password_confirmation, :phone_number)
  end
end
