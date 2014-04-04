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
    assert_not_nil assigns(:cart)
  end

  test "should update line items" do
    sign_in users(:buyer)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    patch :update, cart: {line_items_attributes: [{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2}]}
    line_item.reload
    assert_not_equal old_quantity, line_item.quantity
    assert_equal old_quantity*2, line_item.quantity
    assert_response :redirect
    assert_redirected_to cart_path
  end

  test "should remove line item using _destroy" do
    self.current_cart=orders(:cart)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    assert_difference "LineItem.count", -1 do
      patch :update, cart: {line_items_attributes: [{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2, _destroy: '1'}]}
    end
    assert_response :redirect
    assert_redirected_to cart_path
  end

  test "should update and go to checkout on Checkout" do
    self.current_cart=orders(:cart)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    patch :update, commit: "Checkout", cart: {line_items_attributes: [{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2}]}
    line_item.reload
    assert_not_equal old_quantity, line_item.quantity
    assert_equal old_quantity*2, line_item.quantity
    assert_response :redirect
    assert_redirected_to checkout_path
  end

  test "should ask for sign in on checkout" do
    get :checkout
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should allow checkout when signed in" do
    sign_in users(:buyer)
    get :checkout
    assert_response :success
    assert_not_nil assigns(:cart)
  end

  private
    def valid
      @cart||={line_items_attributes: [{product_id: products(:tshirt), quantity: 2}]}
    end
end
