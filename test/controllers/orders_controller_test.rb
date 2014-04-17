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
      assert_select "form", cart_count
    end
  end

  test "should set current cart to selected order" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=users(:buyer).carts.last
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal users(:buyer).carts.first, current_cart
    assert_equal cart, current_cart
  end

  test "should not set current cart to selected order when it belongs to someone else" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=orders(:cart_for_other_user)
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal cart, current_cart
  end

  test "should not set current cart to selected order when it doesn't belong to anyone" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=orders(:cart_without_user)
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal cart, current_cart
  end

  test "should not resume order not in cart status" do
    sign_in users(:buyer)
    cart=orders(:placed)
    patch :set_current, id: cart.id
    assert_not_equal cart.cart_token, cookies[:cart_token]
  end

  test "should redirect to checkout" do
    sign_in users(:buyer)
    cart=users(:buyer).carts.first
    patch :set_current, id: cart.id, submit: "Checkout"
    assert_redirected_to checkout_url
  end

end
