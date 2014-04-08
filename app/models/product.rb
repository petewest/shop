class Product < ActiveRecord::Base
  include Costable
  belongs_to :seller, inverse_of: :products
  validates :seller, presence: true
  validates :name, presence: true

  validates :unit_cost, presence: true, numericality: {only_integer: true}
  validates :currency, presence: true
  validates :weight, numericality: true, allow_blank: true

  has_many :line_items, inverse_of: :product
  has_many :orders, through: :line_items, inverse_of: :products
  has_many :dispatched_orders, -> {dispatched}, through: :line_items, source: :order
  has_many :purchased_by, through: :dispatched_orders, source: :user
  has_many :images, inverse_of: :product, dependent: :destroy
  has_one :main_image, ->{main}, class_name: "Image"
  has_many :stock_levels, inverse_of: :product, dependent: :destroy
  has_many :current_stock, -> {current}, class_name: "StockLevel"


  accepts_nested_attributes_for :images, allow_destroy: true
end
