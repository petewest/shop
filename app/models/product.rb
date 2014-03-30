class Product < ActiveRecord::Base
  belongs_to :seller, inverse_of: :products
  validates :seller, presence: true
  validates :name, presence: true

  has_many :line_items, inverse_of: :product
  has_many :orders, through: :line_items, inverse_of: :products
  has_many :dispatched_orders, -> {dispatched}, through: :line_items, source: :order
  has_many :purchased_by, through: :dispatched_orders, source: :user
end
