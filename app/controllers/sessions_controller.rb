class SessionsController < ApplicationController
  skip_after_action :verify_authorized

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.to_s.strip.downcase)

    if user&.authenticate(params[:password])
      log_in(user)
      redirect_to return_location, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to articles_path, notice: "Logged out."
  end
end
