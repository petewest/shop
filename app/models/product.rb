class Product < ActiveRecord::Base
  belongs_to :seller, inverse_of: :products
  validates :seller, presence: true
  validates :name, presence: true
end
