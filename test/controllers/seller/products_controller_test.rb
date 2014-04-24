require 'test_helper'

class Seller::ProductsControllerTest < ActionController::TestCase
  test "should get index for seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
    product_count=[30, Product.count].min
    assert_equal product_count, assigns(:products).size
    assert_select ".panel", product_count
  end

  test "should not get index for buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :redirect
    assert_redirected_to signin_path
  end
  test "should not get index for anonymous" do
    get :index
    assert_response :redirect
    assert_redirected_to signin_path
  end
end
