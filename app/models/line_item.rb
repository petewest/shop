class LineItem < ActiveRecord::Base
  include Costable
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items, counter_cache: true

  has_many :allocations, inverse_of: :line_item, dependent: :destroy

  validates :quantity, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :product, presence: true
  validates :order, presence: true
  validate :product_for_sale

  validates :product_id, uniqueness: {scope: :order_id, message: "already in order, update quantity and try again"}

  before_save :set_up_on_save


  def copy_cost_from_product
    #this will only run on cart/checkout so shouldn't change
    #after an order has been placed
    self.unit_cost=product.unit_cost
    self.currency=product.currency
    #return self for method chaining
    self
  end

  # find currency from product if none specified
  def currency
    super || product.try(:currency)
  end

  # find unit cost from product if none specified
  def unit_cost
    super || product.try(:unit_cost)
  end

  def cost
    unit_cost*quantity
  end

  def stock_check
    if product.stock_check(quantity)
      true
    else
      errors[:quantity]="is greater than current stock!"
      false
    end
  end

  def take_stock
    product.allocate_stock_to(self)
  end

  def release_stock
    allocations.destroy_all
  end

  def weight
    product.weight.to_f*quantity.to_i if product
  end

  private
    def set_up_on_save
      #by checking against status_was instead of status we'll allow saving of line_items when switching out of cart/checkout
      #if any of them are flagged as dirty
      errors[:base] << "Can't modify line item in non-cart states" and return false unless %w(cart checkout).include?(order.try(:status) || order.try(:status_was))
      copy_cost_from_product
      # Check currency of this product matches currency of the order
      errors[:base] << "Multi-currency orders currently unsupported" and return false unless self.currency==order.currency
    end

    def product_for_sale
      errors[:product]=I18n.t('errors.attributes.product.not_for_sale') if product and !product.for_sale?
    end
end
