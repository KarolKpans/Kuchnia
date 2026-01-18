class User < ApplicationRecord
  has_secure_password

  has_many :recipes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ratings,  dependent: :destroy

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "tylko litery, cyfry i _" }

  validates :password,
            presence: true,
            length: { minimum: 6 },
            if: :password_digest_changed?

  validates :email,
            allow_blank: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "nie wygląda na poprawny email" }

  def admin?
    role == 1
  end
end