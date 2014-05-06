class Product < ActiveRecord::Base
  include Costable
  belongs_to :seller, inverse_of: :products
  belongs_to :master_product, class_name: "Product", inverse_of: :sub_products
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
  has_many :allocations, inverse_of: :product
  has_many :current_stock, -> {current}, class_name: "StockLevel"
  has_many :sub_products, inverse_of: :master_product, foreign_key: "master_product_id", dependent: :destroy


  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: -> (item) {item[:image].blank? and item[:id].nil?}

  ## Methods
  def allocate_stock_to(line_item)
    quantity=line_item.quantity
    result=current_stock.all? do |stock|
      #How many from this item?
      from_this=[quantity,stock.current_quantity].min
      # if we're not taking anything from here try the next one
      next true if from_this==0
      #decrement quantity
      quantity-=from_this
      #create allocation
      allocation=allocations.find_or_initialize_by(line_item: line_item, stock_level: stock)
      allocation.quantity=from_this
      allocation.save
    end
    return true if result and quantity==0
    errors[:quantity]="Insufficient stock"
    raise ActiveRecord::Rollback
  end

  def stock_check(quantity)
    if quantity>current_stock.available
      false
    else
      true
    end
  end
end
