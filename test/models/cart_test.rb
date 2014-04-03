require 'test_helper'

class CartTest < ActiveSupport::TestCase
  test "should be of cart type" do
    cart=Cart.new
    assert cart.is_a?(Cart)
    assert cart.is_a?(Order)
  end

  test "should respond to cart_token" do
    cart=Cart.new
    assert_respond_to cart, :cart_token
  end

  test "should save when valid" do
    cart=Cart.new(valid)
    assert cart.save
  end

  test "should force cart_token to be unique for Cart" do
    cart=Cart.new(valid)
    cart2=Cart.new(valid)
    cart.cart_token="Elephant"
    cart2.cart_token=cart.cart_token
    assert_difference "Cart.count" do
      assert cart.save
    end
    assert_no_difference "Cart.count" do
      assert_not cart2.save
    end
  end


  private
    def valid
      @cart||={user: users(:buyer)}
    end
end
