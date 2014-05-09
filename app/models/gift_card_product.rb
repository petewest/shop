class GiftCardProduct < Product
  # override association class
  has_many :allocations, class_name: "GiftCardAllocation", foreign_key: "product_id"

  def name
    with_cost=" #{ActiveSupport::NumberHelper::NumberToCurrencyConverter.convert(unit_cost/(10.0**currency.decimal_places), unit: currency.symbol)}" if unit_cost and currency
    self.class.model_name.human + "#{with_cost}"
  end

end
