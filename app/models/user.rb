class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: VALID_EMAIL_REGEX}
  validates :name, presence: true, length: {minimum: 2}
  validates :password, length: {minimum: 6}

  before_save { self.email.downcase! }

  has_secure_password

  has_many :sessions, inverse_of: :user, dependent: :destroy
  has_many :orders, inverse_of: :user, dependent: :destroy
  has_many :carts, inverse_of: :user
end
