require 'test_helper'

class CurrenciesControllerTest < ActionController::TestCase
  test "should not get index without sign in" do
    get :index
    assert_response :redirect
  end

  test "should not get index with sign in as buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :redirect
  end

  test "should get index when signed in as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:currencies)
  end
end
