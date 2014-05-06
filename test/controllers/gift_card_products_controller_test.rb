require 'test_helper'

class GiftCardProductsControllerTest < ActionController::TestCase
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
end
