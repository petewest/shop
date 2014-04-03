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

  test "should create a new cart and add item to it" do
    assert_difference "Cart.count" do
      assert_difference "LineItem.count" do
        assert_difference "current_cart.line_items.count" do
          add_to_cart(product: products(:tshirt), quantity: 1)
        end
      end
    end
    assert_not_nil cookies[:cart_token]
  end

  test "should fail gracefully if cookie set incorrectly" do
    cookies[:cart_token]="elephant"
    assert_not_nil current_user
  end

=begin
  test "should remove item from cart" do
    add_to_cart(products(:tshirt), 1)
    assert_difference "current_cart.count", -1 do
      delete :destroy, id: current_cart.map{|k,v| k}.first
    end
    assert_equal "Item removed from cart", flash[:success]
  end

  test "should remove item from cart (js)" do
    add_to_cart(products(:tshirt), 1)
    assert_difference "current_cart.count", -1 do
      delete :destroy, format: :js, id: current_cart.map{|k,v| k}.first
    end
    assert_response :success
  end

  test "should change quantity" do
    product=products(:tshirt)
    add_to_cart(product, 1)
    id=current_cart.map{|k,v| k}.first
    patch :update, id: id, cart: {quantity: "2"}
    assert_equal Hash(product_id: product.id, quantity: "2").stringify_keys, current_cart[id]
    assert_response :redirect
  end

  test "should change quantity (js)" do
    product=products(:tshirt)
    add_to_cart(product, 1)
    id=current_cart.map{|k,v| k}.first
    patch :update, format: :js, id: id, cart: {quantity: "2"}
    assert_equal Hash(product_id: product.id, quantity: "2").stringify_keys, current_cart[id]
    assert_response :success
  end

  test "should not change product id" do
    product=products(:tshirt)
    add_to_cart(product, 1)
    id=current_cart.map{|k,v| k}.first
    patch :update, id: id, cart: {product_id: products(:product_1).id}
    assert_equal Hash(product_id: product.id, quantity: 1).stringify_keys, current_cart[id]
  end

=end

end
