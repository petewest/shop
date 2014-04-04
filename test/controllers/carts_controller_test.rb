require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  test "should get set current_cart to be a new Cart when no history present" do
    cart=nil
    assert_no_difference "Cart.count" do
      cart=current_cart
    end
    assert cart.is_a?(Cart)
    assert cart.new_record?
  end

  test "should retrieve cart from cookie if present" do
    cart=Cart.create
    cookies[:cart_token]=cart.cart_token
    assert_equal cart, current_cart
  end

  test "should retrieve from user if no cookie present and only one cart item for user" do
    sign_in users(:buyer)
    assert_equal orders(:cart), current_cart
  end

  test "should retrieve from cookie if signed in but with cookie present" do
    sign_in users(:buyer)
    cart=Cart.create
    cookies[:cart_token]=cart.cart_token
    assert_equal cart, current_cart
    assert_not_equal cart, current_user.carts.first
  end

  test "should fail gracefully if cookie set incorrectly" do
    cookies[:cart_token]="elephant"
    assert_not_nil current_cart
    assert_nil cookies[:cart_token]
  end

  test "should not destroy without login" do
    cookies[:cart_token]="cart_token_for_cart"
    assert_no_difference "Cart.count" do
      delete :destroy
    end
  end

  test "should clear cookie without login" do
    cookies[:cart_token]="cart_token_for_cart"
    delete :destroy
    assert_nil cookies[:cart_token]
  end

  test "should clear cart when logged in if belongs to user" do
    sign_in Cart.first.user
    assert_difference "Cart.count",-1 do
      delete :destroy
    end
  end

  test "should not clear cart if it belongs to a different user" do
    sign_in users(:seller)
    cookies[:cart_token]=orders(:cart).cart_token
    assert_not_equal current_user, current_cart.user
    assert_no_difference "Cart.count" do
      delete :destroy
    end
  end

  test "should show current cart" do
    get :show
    assert_response :success
    assert_select "h1"
  end
end
