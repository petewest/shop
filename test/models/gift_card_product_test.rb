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

  private
    def valid
      {seller: users(:seller), currency: currencies(:gbp), unit_cost: 2000}
    end
end
