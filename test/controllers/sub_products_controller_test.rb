require 'test_helper'

class SubProductsControllerTest < ActionController::TestCase
  def setup
    @product=products(:tshirt)
  end

  test "should get new page" do
    sign_in users(:seller)
    get :new, product_id: @product.id
    assert_response :success
  end

  test "should not get new page" do
    get :new, product_id: @product.id
    assert_redirected_to  signin_path
  end

  test "should not get new page for buyer" do
    sign_in users(:buyer)
    get :new, product_id: @product.id
    assert_redirected_to  signin_path
  end

  test "should get an index" do
    sign_in users(:seller)
    get :index, product_id: @product.id
    assert_response :success
    
  end


end
