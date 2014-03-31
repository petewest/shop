require 'test_helper'

class CartControllerTest < ActionController::TestCase
  test "should get cart without login" do
    get :index
    assert_response :success
  end

  test "should remove item from cart" do
    add_to_cart(products(:tshirt), 1)
    assert_difference "current_cart.count", -1 do
      delete :destroy, id: current_cart.map{|k,v| k}.first
    end
  end

end
