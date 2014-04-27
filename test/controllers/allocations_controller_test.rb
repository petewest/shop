require 'test_helper'

class AllocationsControllerTest < ActionController::TestCase
  test "should not get index as buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end
  test "should not get index as anonymous" do
    get :index
    assert_redirected_to signin_path
  end
  test "should get index as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:allocations)
    assert_equal Allocation.count, assigns(:allocations).size
  end

  test "should get index with product_id" do
    sign_in users(:seller)
    product=products(:product_0)
    get :index, product_id: product.id
    assert_response :success
    assert_equal product.allocations.count, assigns(:allocations).size
  end

  test "should get index with stock_level_id" do
    sign_in users(:seller)
    stock_level=stock_levels(:product_0)
    get :index, stock_level_id: stock_level.id
    assert_response :success
    assert_equal stock_level.allocations.count, assigns(:allocations).size
  end

end
