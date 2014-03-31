require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  test "should redirect without login" do
    get :new
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should get cart without login" do
    get :cart
    assert_response :success
  end

end
