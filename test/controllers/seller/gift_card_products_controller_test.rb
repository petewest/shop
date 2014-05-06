require 'test_helper'

class Seller::GiftCardProductsControllerTest < ActionController::TestCase
  test "should have new action for seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
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
    assert_difference "GiftCardProduct.count" do
      post :create, gift_card_product: valid
    end
  end

  test "should have index action" do
    sign_in users(:seller)
  end

  private
    def valid
      {currency_id: currencies(:gbp).id, unit_cost: 2000}
    end
end
