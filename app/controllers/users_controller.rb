class UsersController < ApplicationController
  def new
    @user = User.new
    render template: "rejestracja"
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Konto utworzone! Jesteś zalogowany."
    else
      render template: "rejestracja", status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :email,
      :password,
      :password_confirmation
    )
  end
end