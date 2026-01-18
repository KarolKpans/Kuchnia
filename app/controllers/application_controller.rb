class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path,
                alert: "Musisz być zalogowany, aby wykonać tę operację"
  end

  def require_login_with_return
    return if logged_in?

    session[:return_to] = request.original_fullpath
    redirect_to login_path,
                alert: "Musisz się zalogować, aby kontynuować"
  end

  def require_admin
    unless logged_in? && current_user.admin?
      redirect_to root_path,
                  alert: "Tylko administrator ma dostęp do tej sekcji"
      return false
    end
  end
end
