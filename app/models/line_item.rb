class LineItem < ActiveRecord::Base
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items

  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :product, presence: true
  validates :order, presence: true

  before_save :order_status_on_save



  private
    def order_status_on_save
      return false if order.try(:status)!="cart"
    end
end
