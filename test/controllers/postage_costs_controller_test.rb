require 'test_helper'

class PostageCostsControllerTest < ActionController::TestCase
  test "should not be accessible without login" do
    get :index
    assert_redirected_to signin_path
  end


  test "should not be accessible with buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should be accessible with seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:postage_costs)
    assert_select "table"
  end

  test "should have an edit action" do
    sign_in users(:seller)
    postage_cost=PostageCost.first
    get :edit, id: postage_cost.id
    assert_response :success
    assert_not_nil assigns(:postage_cost)
  end
end
