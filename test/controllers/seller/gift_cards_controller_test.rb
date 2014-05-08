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
end
