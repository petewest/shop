require 'test_helper'

class RedemptionTest < ActiveSupport::TestCase
  def setup
    @redemption=Redemption.new(valid)
  end

  test "should save when valid" do
    assert @redemption.save
  end

  test "should not save without order" do
    @redemption.order=nil
    assert_not @redemption.valid?
  end

  test "should not save without gift_card" do
    @redemption.gift_card=nil
    assert_not @redemption.valid?
  end

  test "should decrement gift_card balance on save" do
    order_total=@redemption.order.cost
    gift_card_value=@redemption.gift_card.current_value
    redemption_value=[gift_card_value, order_total].min
    new_gift_card_balance=gift_card_value-redemption_value
    @redemption.save
    @redemption.gift_card.reload
    assert_equal new_gift_card_balance, @redemption.gift_card.current_value
    assert_equal redemption_value, @redemption.value
  end

  test "should copy currency from gift_card to self on save" do
    @redemption.save
    assert_equal @redemption.gift_card.currency, @redemption.currency
  end

  test "should not allow order and gift_card currencies to mismatch" do
    @redemption.gift_card=gift_cards(:ten_dollars)
    assert_not @redemption.valid?
  end

  test "should not allow changes once saved" do
    @redemption.save
    @redemption.order=orders(:dispatched)
    assert_not @redemption.save
  end

  test "should add balance back to gift_card on destroy" do
    value=@redemption.gift_card.current_value
    @redemption.save
    @redemption.destroy
    @redemption.gift_card.reload
    assert_equal value, @redemption.gift_card.current_value
  end


  private
    def valid
      {order: orders(:paid), gift_card: gift_cards(:ten_pounds)}
    end
end
