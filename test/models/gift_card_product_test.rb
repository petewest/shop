require 'test_helper'

class GiftCardProductTest < ActiveSupport::TestCase
  def setup
    @gift_card_product=GiftCardProduct.new(valid)
  end
  test "should have name of 'Gift card'" do
    assert_equal "Gift Card", GiftCardProduct.new.name
  end

  test "should create when valid" do
    assert @gift_card_product.save
  end

  test "shouldn't create without seller" do
    @gift_card_product.seller=nil
    assert_not @gift_card_product.valid?
  end

  test "shouldn't create without currency" do
    @gift_card_product.currency=nil
    assert_not @gift_card_product.valid?
  end

  test "shouldn't create without unit_cost" do
    @gift_card_product.unit_cost=nil
    assert_not @gift_card_product.valid?
  end

  test "should create a new gift_card when told to allocate_stock" do
    order=orders(:gift_card_order)
    line_item=line_items(:gift_card_tenner)
    gift_card_product=products(:gift_card_product)
    assert_difference "GiftCard.count" do
      assert_difference "GiftCardAllocation.count" do
        assert_difference "gift_card_product.current_stock.available", -1 do
          gift_card_product.allocate_stock_to(line_item)
        end
      end
    end
  end

  test "should create multiple new gift_cards based on quantity when told to allocate_stock" do
    order=orders(:gift_card_order)
    line_item=line_items(:gift_card_tenner)
    quantity=2
    line_item.quantity=quantity
    line_item.save
    gift_card_product=products(:gift_card_product)
    assert_difference "GiftCard.count", quantity do
      assert_difference "GiftCardAllocation.count" do
        assert_difference "gift_card_product.current_stock.available", -1*quantity do
          gift_card_product.allocate_stock_to(line_item)
        end
      end
    end
  end

  private
    def valid
      {seller: users(:seller), currency: currencies(:gbp), unit_cost: 2000}
    end
end
