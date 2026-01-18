class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    render template: "logowanie"
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Zalogowano pomyślnie!"
    else
      flash.now[:alert] = "Nieprawidłowa nazwa użytkownika lub hasło"
      render template: "logowanie", status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Wylogowano"
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end
end
