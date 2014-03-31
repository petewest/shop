require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "should respond to user" do
    order=Order.new
    assert_respond_to order, :user
  end

  test "should respond to status" do
    order=Order.new
    assert_respond_to order, :status
  end

  test "should respond to placed?" do
    order=Order.new
    assert_respond_to order, :placed?
  end

  test "should respond to cart?" do
    order=Order.new
    assert_respond_to order, :cart?
  end

  test "should respond to paid?" do
    order=Order.new
    assert_respond_to order, :paid?
  end

  test "should respond to dispatched?" do
    order=Order.new
    assert_respond_to order, :dispatched?
  end

  test "should save when valid" do
    order=Order.new(valid)
    assert_not_nil order.save
  end

  test "should have a status of cart on save (if none other set)" do
    order=Order.new(valid)
    assert_not_nil order.save
    assert_equal "cart", order.status
    assert order.cart?
  end

  test "should not save without user" do
    order=Order.new(valid.except(:user))
    assert_not order.save
  end

  test "should respond to line_items" do
    order=Order.new
    assert_respond_to order, :line_items
  end

  test "should have pending scope" do
    assert_respond_to Order, :pending
  end

  test "pending scope should only contain pending orders" do
    pending_orders=Order.pending
    assert pending_orders.all?{ |o| o.status.in? %w(placed paid) }
  end

  private
    def valid
      @order||={user: users(:buyer)}
    end
end