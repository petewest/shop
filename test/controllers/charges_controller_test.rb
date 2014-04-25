require 'test_helper'

class ChargesControllerTest < ActionController::TestCase
  test "should not get index for buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should not get index for anonymous" do
    get :index
    assert_redirected_to signin_path
  end

  test "should get index for seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:charges)
  end
end
