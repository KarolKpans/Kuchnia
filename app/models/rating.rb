class Rating < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :recipe_id, message: "już oceniłeś ten przepis" }
end