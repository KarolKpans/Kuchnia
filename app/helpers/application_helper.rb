module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def render_error(object, field)
    return unless object&.errors&.any?

    if object.errors[field].present?
      content_tag :span,
                  object.errors[field].join(", "),
                  class: "text-red-600 text-sm mt-1 block"
    end
  end
end