require 'test_helper'

class CartControllerTest < ActionController::TestCase
  #test "should get cart without login" do
  #  get :index
  #  assert_response :success
  #end

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

end
