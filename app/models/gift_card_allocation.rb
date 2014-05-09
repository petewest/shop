class GiftCardAllocation < Allocation
  has_many :gift_cards, foreign_key: "allocation_id"
  private
    def take_stock
      super
      if quantity_changed?
        quantity_difference=quantity-quantity_was.to_i
        quantity.times do
          gift_cards<<GiftCard.create(
            buyer: line_item.order.user,
            start_value: product.unit_cost,
            currency: product.currency
          )
        end
      end
    end
end
