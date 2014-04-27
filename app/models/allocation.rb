class Allocation < ActiveRecord::Base
  ## Relationships
  belongs_to :line_item, inverse_of: :allocations
  belongs_to :stock_level, inverse_of: :allocations
  belongs_to :product, inverse_of: :allocations

  ## Validations
  validates :line_item, presence: true, uniqueness: {scope: :stock_level}
  validates :stock_level, presence: true
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}

  ## Callbacks
  before_save :set_product
  after_save :take_stock
  after_destroy :release_stock

  def release_stock
    stock_level.current_quantity+=quantity
    stock_level.save
  end

  private
    def set_product
      self.product_id=line_item.product_id
    end

    def take_stock
      stock_level.current_quantity-=quantity-quantity_was.to_i if quantity_changed?
      stock_level.save!
    end
end
