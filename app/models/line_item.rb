class LineItem < ActiveRecord::Base
  include Costable
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items

  has_many :allocations, inverse_of: :line_item

  validates :quantity, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :product, presence: true
  validates :order, presence: true

  validates :product_id, uniqueness: {scope: :order_id, message: "item already in order, update quantity and try again"}

  before_save :set_up_on_save


  def copy_cost_from_product
    #this will only run on cart/checkout so shouldn't change
    #after an order has been placed
    self.unit_cost=product.unit_cost
    self.currency=product.currency
    #return self for method chaining
    self
  end

  def cost
    ((unit_cost || product.unit_cost)*self.quantity) / 10.0**currency.try(:decimal_places).to_i
  end

  def stock_check
    quantity<product.stock_levels.current.map(&:current_quantity).sum
  end

  def take_stock
    counter=quantity
    result=product.stock_levels.current.all? do |stock|
      #lock this item while we work on it
      stock.lock!
      #How many from this item?
      from_this=[counter,stock.current_quantity].min
      #decrement counter
      counter-=from_this
      #decrement current quantity
      stock.current_quantity-=from_this
      #save item and release lock
      stock.save
    end
    raise ActiveRecord::Rollback unless result and counter==0
  end


  private
    def set_up_on_save
      #by checking against status_was instead of status we'll allow saving of line_items when switching out of cart/checkout
      #if any of them are flagged as dirty
      errors[:base] << "Can't modify line item in non-cart states" and return false unless %w(cart checkout).include?(order.try(:status) || order.try(:status_was))
      copy_cost_from_product
    end
end
