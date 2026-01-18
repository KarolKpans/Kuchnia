class Comment < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :comment, presence: true, length: { minimum: 3, maximum: 2000 }

  default_scope { order(created_at: :desc) }
end
