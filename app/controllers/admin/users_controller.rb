module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.order(created_at: :desc)
    end

    def destroy
      @user = User.find(params[:id])
      if @user == current_user
        redirect_to admin_users_path, alert: "Nie możesz usunąć własnego konta!"
        return
      end

      @user.destroy
      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: "Użytkownik usunięty" }
        format.turbo_stream { render turbo_stream: turbo_stream.remove("user_#{@user.id}") }
      end
    end
  end
end