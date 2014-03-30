class LineItem < ActiveRecord::Base
  belongs_to :product, inverse_of: :line_items
  belongs_to :order, inverse_of: :line_items
end
