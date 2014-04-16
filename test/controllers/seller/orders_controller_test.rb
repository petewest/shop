require 'test_helper'

class Seller::OrdersControllerTest < ActionController::TestCase
  test "should not get index as anon" do
    get :index
    assert_redirected_to signin_path
  end

  test "should not get index as buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should get index as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end
end
