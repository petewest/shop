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

end
