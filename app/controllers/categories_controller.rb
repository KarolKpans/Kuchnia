class CategoriesController < ApplicationController
  def show
    @category = Category.find_by!(slug: params[:slug])
    @recipes  = @category.recipes.order(created_at: :desc)

    render template: "categories"
  end
end