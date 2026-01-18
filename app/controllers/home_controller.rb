class HomeController < ApplicationController
  def index
    @categories = Category.all.order(:name)

    render template: "index"
  end
end