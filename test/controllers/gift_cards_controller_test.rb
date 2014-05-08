require 'test_helper'

class GiftCardsControllerTest < ActionController::TestCase
  test "should have index action for buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_select "h1","Gift cards"
    assert_not_nil assigns(:gift_cards)
    assert assigns(:gift_cards).include?(gift_cards(:ten_pounds))
    [:other_user, :no_user, :bought_by_buyer].each do |item|
      assert_not assigns(:gift_cards).include?(gift_cards(item)), "Contains: #{item}"
    end
    assert_select ".gift_card", assigns(:gift_cards).count
    assert_select "a[href=#{redeem_gift_cards_path}]", "Redeem"
  end
  test "should not have index action for anonymous" do
    get :index
    assert_redirected_to signin_path
  end
end
