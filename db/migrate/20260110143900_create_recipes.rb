class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :user,           null: false, foreign_key: true
      t.string     :title,          null: false
      t.text       :description
      t.text       :ingredients,    null: false
      t.integer    :preparation_time
      t.references :category,       null: true,  foreign_key: true

      t.timestamps
    end

    add_index :recipes, :title
  end
end