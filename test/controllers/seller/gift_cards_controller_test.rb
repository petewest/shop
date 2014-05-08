require 'test_helper'

class Seller::GiftCardsControllerTest < ActionController::TestCase
  test "should have new action for seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert_select "h1", "Issue new gift card"
    assert_select "form"
    assert_select "select[name='gift_card[redeemer_id]']"
    assert_select "select[name='gift_card[currency_id]']"
    assert_select "input[name='gift_card[unit_cost]']"
    assert_select "label", {text: "Unit cost", count: 0}
    assert_select "input[type=submit]"
  end
  test "should not have new action for buyer" do
    sign_in users(:buyer)
    get :new
    assert_redirected_to signin_path
  end
  test "should not have new action for anonymous" do
    get :new
    assert_redirected_to signin_path
  end

  test "should have create action for seller" do
    sign_in users(:seller)
    assert_difference "current_user.gift_cards_bought.count" do
      assert_difference "users(:buyer).gift_cards_redeemed.count" do
        assert_difference "GiftCard.count" do
          put :create, gift_card: valid
        end
      end
    end
    assert_redirected_to seller_gift_cards_path
  end

  test "should not have create action for buyer" do
    sign_in users(:buyer)
    assert_no_difference "current_user.gift_cards_bought.count" do
      assert_no_difference "users(:buyer).gift_cards_redeemed.count" do
        assert_no_difference "GiftCard.count" do
          put :create, gift_card: valid
        end
      end
    end
    assert_redirected_to signin_path
  end

  test "should not have create action for anonymous" do
    assert_no_difference "users(:buyer).gift_cards_redeemed.count" do
      assert_no_difference "GiftCard.count" do
        put :create, gift_card: valid
      end
    end
    assert_redirected_to signin_path
  end

  test "should have index action for seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
  end

  private
    def valid
      {redeemer_id: users(:buyer).id, currency_id: currencies(:gbp).id, unit_cost: 1000}
    end
end
