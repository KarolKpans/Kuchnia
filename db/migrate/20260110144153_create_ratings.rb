class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,   null: false, foreign_key: { on_delete: :cascade }
      t.integer :rating, null: false

      t.timestamps
    end

    add_index :ratings, [:recipe_id, :user_id], unique: true
    add_check_constraint :ratings,
                         "rating >= 1 AND rating <= 5",
                         name: "ratings_rating_between_1_and_5"
  end
end