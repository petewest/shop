require 'test_helper'

class GiftCardAllocationTest < ActiveSupport::TestCase
  # More tests for creating gift cards when allocating stock can be found in gift_card_product_test.rb
  # due to the nature of this model not regularly being accessed directly

  def setup
    @gift_card_allocation=GiftCardAllocation.new(valid)
  end

  test "should have a 'gift_cards' relationship (not present in allocation)" do
    assert_respond_to @gift_card_allocation, :gift_cards
  end

  test "should create gift cards when told to take_stock" do
    assert_difference "GiftCard.count", valid[:quantity] do
      assert_difference "@gift_card_allocation.stock_level.current_quantity", -1*valid[:quantity] do
        assert @gift_card_allocation.save
      end
    end
  end

  test "should delete gift cards when destroyed" do
    @gift_card_allocation.save
    assert_difference "GiftCard.count", -1 do
      @gift_card_allocation.destroy
    end
  end


  private
    def valid 
      {line_item: line_items(:gift_card_tenner), stock_level: stock_levels(:gift_card_tenner), quantity: line_items(:gift_card_tenner).quantity}
    end
end
