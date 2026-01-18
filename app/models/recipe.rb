class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many :ratings, dependent: :destroy

  has_many :comments, dependent: :destroy

  has_one_attached :image

  has_many :commenting_users, through: :comments, source: :user
  has_many :rating_users,     through: :ratings,  source: :user

  validates :image,
            content_type: {
              in: %w[image/jpeg image/png image/gif image/webp],
              message: "musi być zdjęciem (jpg, png, gif, webp)"
            },
            size: {
              less_than: 5.megabytes,
              message: "zdjęcie musi być mniejsze niż 5 MB"
            }

  def average_rating
    return 0 unless ratings.any?

    ratings.average(:rating).to_f.round(1)
  end

  def ratings_count
    ratings.count
  end

  scope :search_by_title, ->(query) {
    where("LOWER(title) LIKE ?", "%#{query.downcase}%") if query.present?
  }
end
