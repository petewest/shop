require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  test "should redirect without login" do
    get :new
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should create order when valid" do
    sign_in users(:without_cart)
    assert_difference "Order.count" do
      assert_difference "LineItem.count",2 do
        put :create, order: valid
      end
    end
    assert_not_nil assigns(:order)
    assert_nil cookies[:cart_token]
    assert_equal 0, current_cart.line_items.count
  end

  test "should not create order when not signed in" do
    assert_no_difference "Order.count" do
      assert_no_difference "LineItem.count" do
        put :create, order: valid
      end
    end
  end



  private
  def valid
    @order||={line_items_attributes: [{product_id: products(:tshirt).id, quantity: 3}, {product_id: products(:product_1).id, quantity: 1}]}
  end

end
