class GiftCardProduct < Product
  def name
    self.class.model_name.human
  end

  # calling 'allocate_stock_to' will also create a gift_card item
  def allocate_stock_to(line_item)
    super and line_item.quantity.times { GiftCard.create(buyer: line_item.order.user, start_value: unit_cost, currency: currency) }
  end
end
