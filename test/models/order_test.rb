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

  test "should save without user" do
    order=Order.new(valid.except(:user))
    assert order.save
  end

  test "should not save without user in non-cart states" do
    order=Order.new(valid.except(:user))
    order.status=Order.statuses[:cart]
    assert order.valid?
    assert Order.statuses.except(:cart).none?{ |s,i|
      order.status=Order.statuses[s]
      order.valid?
    }
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

  test "should respond to costs" do
    order=Order.new
    assert_respond_to order, :costs
  end

  test "should contain sum of line items in cost" do
    order=Order.new
    products=[products(:tshirt)]
    order.products=products
    order.line_items.first.quantity=2
    order.line_items.each(&:copy_cost_from_product)
    assert_equal 1, order.costs.count
    assert currencies(:gbp), Currency.find(order.costs.first[:currency_id])
    assert_equal products.first.cost*2, order.costs.first[:cost]
  end

  test "should combine costs by currency" do
    order=Order.new
    products=[products(:tshirt), products(:other_currency), products(:mug)]
    order.products=products
    order.line_items.first.quantity=2
    order.line_items.each(&:copy_cost_from_product)
    assert_equal 2, order.costs.count
    assert currencies(:gbp), Currency.find(order.costs.first[:currency_id])
    assert_equal 50, order.costs.first[:cost]
    assert_equal 30, order.costs.last[:cost]
  end

  test "should change class when changing status" do
    order=Cart.create(valid)
    id=order.id
    assert order.is_a?(Cart)
    order.placed!
    assert_equal "placed", order.status
    assert_raises ActiveRecord::RecordNotFound do
      order.reload
    end
    order=Order.find(id)
    assert_not_nil order
    assert_not order.is_a?(Cart)
  end

  test "should save without line items if cart" do
    o=Order.new(valid.except(:line_items_attributes))
    o.status=Order.statuses[:cart]
    assert o.valid?
  end

  test "should not save without line items if in any non-cart state" do
    order=Order.new(valid.except(:line_items_attributes))
    assert Order.statuses.except(:cart).none?{ |s,i|
      order.status=Order.statuses[s]
      order.valid?
    }
  end

  private
    def valid
      @order||={user: users(:buyer), line_items_attributes: [{product_id: products(:mug).id, quantity: 1}]}
    end
end
