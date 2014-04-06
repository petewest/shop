class Currency < ActiveRecord::Base
  validates :iso_code, presence: true, uniqueness: true, length: {is: 3}
  validates :symbol, presence: true
  validates :decimal_places, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  has_many :products, dependent: :nullify, inverse_of: :currency
  has_many :line_items, dependent: :nullify, inverse_of: :currency
end
