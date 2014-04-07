require 'test_helper'

class StockLevelsControllerTest < ActionController::TestCase
  def setup
    @product=products(:tshirt)
  end
  
  test "should not be accessible from anonymous" do
    get :index, product_id: @product.id
    assert_response :redirect
  end

  test "should not be accessible from non-seller account" do
    sign_in users(:buyer)
    get :index, product_id: @product.id
    assert_response :redirect
  end

  test "should be accessible from seller account" do
    sign_in users(:seller)
    get :index, product_id: @product.id
    assert_response :success
  end



end
