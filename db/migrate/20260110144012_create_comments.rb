class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,   null: false, foreign_key: { on_delete: :cascade }
      t.text :comment, null: false

      t.timestamps
    end
  end
end