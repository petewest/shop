require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  test "should redirect without login" do
    get :index
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should show page after login" do
    sign_in users(:buyer)
    get :index
    assert_response :success
  end

  test "should show a list of all the users orders" do
    sign_in users(:buyer)
    order_count=users(:buyer).orders.count
    cart_count=users(:buyer).orders.cart.count
    line_item_count=users(:buyer).orders.map(&:line_items).map(&:count).sum
    get :index
    assert_not_nil assigns(:orders)
    assert_not assigns(:orders).include?(orders(:cart_without_user))
    assert_equal order_count, assigns(:orders).count
    assert_select "div.order_list" do
      assert_select ".order_item", order_count
      assert_select ".order_status_cart", cart_count
      assert_select ".order_summary div.order_line_item", line_item_count
    end
  end


end
