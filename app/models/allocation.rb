class Allocation < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :stock_level

  validates :line_item, presence: true, uniqueness: {scope: :stock_level}
  validates :stock_level, presence: true
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}

  def release_stock
    stock_level.current_quantity+=quantity
    stock_level.save
  end
end
