class LineItem < ActiveRecord::Base
  include Costable
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items

  validates :quantity, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :product, presence: true
  validates :order, presence: true

  before_save :set_up_on_save


  def copy_cost_from_product
    if (cost.nil? or cost.new_record?) and product.cost
      self.cost=product.cost.dup
      self.cost.value*=quantity
    end
    #return self for method chaining
    self
  end


  private
    def set_up_on_save
      return false unless %w(cart placed).include?(order.try(:status))
      copy_cost_from_product
    end
end
