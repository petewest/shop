class StockLevel < ActiveRecord::Base
  belongs_to :product

  validates :product, presence: true
  validates :due_at, presence: true
end
