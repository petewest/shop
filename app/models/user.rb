class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  ##Validations

  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: VALID_EMAIL_REGEX}
  validates :name, presence: true, length: {minimum: 2}

  #Validate password if it's a new record, or we're changing password (password present)
  validates :password, presence: true, length: {minimum: 6}, if: -> { new_record? or !password.nil? }
  validates :password_confirmation, presence: true, if: -> { password.present? }

  before_save { self.email.downcase! }

  has_secure_password

  ## Relationships
  has_many :sessions, inverse_of: :user, dependent: :destroy
  has_many :orders, inverse_of: :user, dependent: :destroy
  has_many :carts, inverse_of: :user
  has_many :addresses, inverse_of: :user, dependent: :destroy
  has_many :allocations, through: :orders

end
