require 'test_helper'

class RedemptionsControllerTest < ActionController::TestCase
  test "should have create action for buyer" do
    sign_in users(:buyer)
    order=orders(:placed)
    gift_card=gift_cards(:ten_pounds)
    assert_difference "Redemption.count" do
      assert_difference "order.reload.redemptions.count" do
        assert_difference "order.reload.gift_cards.count" do
          patch :create, order_id: order.id, redemption: valid
        end
      end
    end
    assert_redirected_to pay_order_path(order)
    assert_equal "Gift card added to order", flash[:success]
  end

  test "should not have create action for anonymous" do
    order=orders(:placed)
    gift_card=gift_cards(:ten_pounds)
    assert_no_difference "Redemption.count" do
      assert_no_difference "order.reload.redemptions.count" do
        assert_no_difference "order.reload.gift_cards.count" do
          patch :create, order_id: order.id, redemption: valid
        end
      end
    end
    assert_redirected_to signin_path
  end

  private
    def valid
      {gift_card_id: gift_cards(:ten_pounds).id}
    end
end
