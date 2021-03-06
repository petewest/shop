require 'test_helper'

class GiftCardProductsControllerTest < ActionController::TestCase
  test "should have index action for buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_select "title", "Shop! | Gift cards available"
    assert_not_nil assigns(:gift_card_products)
  end

  test "should not show gift cards no longer for sale" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_not assigns(:gift_card_products).include?(products(:gift_card_not_for_sale))
  end

  test "should not have index action for anonymous" do
    get :index
    assert_redirected_to signin_path
  end
end
