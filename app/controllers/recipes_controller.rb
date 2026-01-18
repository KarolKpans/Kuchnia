class RecipesController < ApplicationController
  before_action :require_login, only: %i[
    new create edit update destroy rate
    create_comment update_comment destroy_comment edit_comment_frame
    my_recipes
  ]

  before_action :set_recipe, only: %i[
    show edit update destroy rate
    create_comment update_comment destroy_comment edit_comment_frame
  ]

  before_action :require_owner, only: %i[edit update destroy]
  def show
    @ratings = @recipe.ratings.order(created_at: :desc)
    @user_rating = @recipe.ratings.find_by(user: current_user) if logged_in?
    @comment = Comment.new
    @comments = @recipe.comments.order(created_at: :desc)
  end
  def new
    @recipe = Recipe.new
    @categories = Category.all.order(:name)
  end
  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      redirect_to category_recipes_path(@recipe.category.slug),
                  notice: "Przepis został dodany!"
    else
      @categories = Category.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @categories = Category.all.order(:name)
  end
  def update
    if @recipe.update(recipe_params)
      redirect_to my_recipes_path
    else
      @categories = Category.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    category = @recipe.category
    @recipe.destroy
    redirect_to my_recipes_path

  end
  def rate
    rating = @recipe.ratings.find_or_initialize_by(user: current_user)

    if rating.update(rating_params)
      respond_to do |format|
        format.html { redirect_to @recipe, notice: "Ocena została zapisana!" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "recipe_ratings",
            partial: "recipes/ratings",
            locals: { recipe: @recipe }
          )
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @recipe, alert: "Nie udało się zapisać oceny" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "recipe_ratings",
            partial: "recipes/ratings",
            locals: { recipe: @recipe }
          )
        end
      end
    end
  end
  def create_comment
    @comment = @recipe.comments.build(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("no_comments_message"),
            turbo_stream.prepend(
              "comments_container",
              partial: "comments/comment",
              locals: { comment: @comment }
            ),
            turbo_stream.replace(
              "new_comment_form",
              partial: "comments/form",
              locals: { recipe: @recipe, comment: Comment.new }
            ),
            turbo_stream.replace(
              "comments_count",
              "<h5>Komentarze (#{@recipe.comments.count})</h5>".html_safe
            )
          ]
        end
        format.html { redirect_to @recipe, notice: "Komentarz dodany!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment_form",
            partial: "comments/form",
            locals: { recipe: @recipe, comment: @comment }
          )
        end
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end
  def edit_comment_frame
    @comment = @recipe.comments.find(params[:comment_id])

    return head :forbidden unless current_user == @comment.user || current_user == @recipe.user

    render turbo_stream: turbo_stream.replace(
      "comment_#{@comment.id}",
      partial: "comments/edit_form",
      locals: { comment: @comment, recipe: @recipe }
    )
  end
  def update_comment
    @comment = @recipe.comments.find(params[:comment_id])
    return head :forbidden unless current_user == @comment.user  # tylko autor komentarza

    if @comment.update(comment_params)
      render turbo_stream: turbo_stream.replace(
        "comment_#{@comment.id}",
        partial: "comments/comment",
        locals: { comment: @comment }
      )
    else
      render turbo_stream: turbo_stream.replace(
        "comment_#{@comment.id}",
        partial: "comments/edit_form",
        locals: { comment: @comment, recipe: @recipe }
      )
    end
  end
  def destroy_comment
    @comment = @recipe.comments.find(params[:comment_id])
    return head :forbidden unless current_user == @comment.user  # tylko autor komentarza

    @comment.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("comment_#{@comment.id}"),
          turbo_stream.replace(
            "comments_count",
            "<h5>Komentarze (#{@recipe.comments.count})</h5>".html_safe
          )
        ]
      end
      format.html { redirect_to @recipe, notice: "Komentarz usunięty" }
    end
  end
  def my_recipes
    @recipes = current_user.recipes
                           .includes(:category)
                           .order(created_at: :desc)
    render "my_recipes"
  end

  def index
    if params[:query].present?
      @query = params[:query]
      @recipes = Recipe
                   .where("title LIKE ?", "%#{@query}%")
                   .order(created_at: :desc)
    else
      @recipes = []
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find_by(id: params[:id])
    redirect_to root_path, alert: "Przepis nie istnieje" unless @recipe
  end

  def require_owner
    redirect_to root_path, alert: "To nie jest Twój przepis!" unless @recipe.user == current_user
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :ingredients,
      :preparation_time, :category_id, :image
    )
  end

  def require_login
    redirect_to login_path, alert: "Musisz być zalogowany" unless current_user
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def rating_params
    params.require(:rating).permit(:rating)
  end
end