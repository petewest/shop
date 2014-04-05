class LineItem < ActiveRecord::Base
  include Costable
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items

  validates :quantity, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :product, presence: true
  validates :order, presence: true

  validates :product_id, uniqueness: {scope: :order_id, message: "item already in order, update quantity and try again"}

  before_save :set_up_on_save


  def copy_cost_from_product
    #this will only run on cart/checkout so shouldn't change
    #after an order has been placed
    self.unit_cost=product.cost
    self.currency=product.currency
    #return self for method chaining
    self
  end

  def cost
    (self.unit_cost || product.cost)*self.quantity
  end


  private
    def set_up_on_save
      return false unless %w(cart checkout).include?(order.try(:status))
      copy_cost_from_product
    end
end
