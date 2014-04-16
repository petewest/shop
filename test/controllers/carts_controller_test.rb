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
    patch :update, cart: {line_items_attributes: {"0"=>{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2}}}
    line_item.reload
    assert_not_equal old_quantity, line_item.quantity
    assert_equal old_quantity*2, line_item.quantity
    assert_response :redirect
    assert_redirected_to cart_path
  end

  test "should remove line item using _destroy" do
    sign_in users(:buyer)
    self.current_cart=orders(:cart)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    assert_difference "LineItem.count", -1 do
      patch :update, cart: {line_items_attributes: {"0"=>{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2, _destroy: '1'}}}
    end
    assert_response :redirect
    assert_redirected_to cart_path
  end

  test "should remove line item using quantity 0" do
    sign_in users(:buyer)
    self.current_cart=orders(:cart)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    assert_difference "LineItem.count", -1 do
      patch :update, cart: {line_items_attributes: {"0"=>{id: line_item.id, product_id: line_item.product_id, quantity: 0, _destroy: '0'}}}
    end
    assert_response :redirect
    assert_redirected_to cart_path
  end


  test "should update and go to checkout on Checkout" do
    sign_in users(:buyer)
    self.current_cart=orders(:cart)
    line_item=current_cart.line_items.first
    old_quantity=line_item.quantity
    patch :update, commit: "Checkout", cart: {line_items_attributes: {"0"=>{id: line_item.id, product_id: line_item.product_id, quantity: old_quantity*2}}}
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
    assert_select ".cart_container div.cart_product", assigns(:cart).line_items.count
    assert_select ".btn_confirm"
  end

  test "should not allow confirm without sign in" do
    patch :confirm
    assert_response 302
  end

  test "should allow confirm when signed in" do
    sign_in users(:without_cart)
    self.current_cart=orders(:cart_without_user)
    patch :confirm
    assert_not_nil assigns(:cart)
    assert_equal current_user, assigns(:cart).user
    assert_equal "placed", assigns(:cart).status
    assert_equal "Thank you for your order!", flash[:success]
    assert_redirected_to order_path(assigns(:cart))
  end

  test "should create new cart if current doesn't belong to user" do
    sign_in users(:without_cart)
    self.current_cart=orders(:cart)
    #clear instance variable as current_cart= sets it
    #for this instance
    @current_cart=nil
    assert_equal orders(:cart).cart_token, cookies[:cart_token]
    assert_not_equal orders(:cart), current_cart
  end

  test "should set cart user if signed in" do
    sign_in users(:without_cart)
    assert_equal current_cart.user, current_user
  end

  test "should not allow you to view someone elses cart" do
    cookies[:cart_token]=orders(:cart).cart_token
    assert_not_equal orders(:cart), current_cart
  end

  test "should tell you basket is empty" do
    get :show
    assert_select "form input[type=submit]", 0
    assert_select "a[href=#{products_path}]", "Go shopping"
  end

  test "should set billing address on order (html)" do
    sign_in users(:buyer)
    cart=users(:buyer).carts.first
    billing_address=users(:buyer).addresses.billing.first
    assert_not_equal billing_address.address, cart.billing.try(:address)
    patch :update_address, cart:{ billing_attributes: { source_address_id: billing_address.id }}
    cart.reload
    assert_equal billing_address.address, cart.billing.address
  end

  test "should not set billing address on order (html)" do
    cart=users(:buyer).carts.first
    billing_address=users(:buyer).addresses.billing.first
    assert_not_equal billing_address.address, cart.billing.try(:address)
    patch :update_address, cart:{ billing_attributes: { source_address_id: billing_address.id }}
    assert_redirected_to signin_path
    cart.reload
    assert_not_equal billing_address.address, cart.billing.try(:address)
  end

  private
    def valid
      @cart||={line_items_attributes: {"0"=>{product_id: products(:tshirt), quantity: 2}}}
    end
end
