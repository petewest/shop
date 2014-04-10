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
    assert order.save
  end

  test "should have a status of cart on save (if none other set)" do
    order=Order.new(valid)
    assert order.save
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
    assert currencies(:gbp), order.costs.first[:currency]
    assert_equal products.first.cost*2, order.costs.first[:cost]
  end

  test "should combine costs by currency" do
    order=Order.new
    products=[products(:tshirt), products(:other_currency), products(:mug)]
    order.products=products
    order.line_items.first.quantity=2
    order.line_items.each(&:copy_cost_from_product)
    assert_equal 2, order.costs.count
    assert currencies(:gbp), order.costs.first[:currency]
    assert_equal 50, order.costs.first[:cost]
    assert_equal 30, order.costs.last[:cost]
  end

  test "should change class when changing status" do
    order=Cart.create(valid)
    order.reload
    id=order.id
    assert order.is_a?(Cart)
    assert order.placed!
    assert_equal "placed", order.status
    assert order.save, "Errors: #{order.errors.inspect}"
    assert_not order.changed?
    assert_raises ActiveRecord::RecordNotFound, "Debug: #{order.inspect} db: #{Order.find(id).inspect} errors: #{order.errors.inspect}" do
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

  test "should not update line_items for items not in this order" do
    order=orders(:cart)
    line_item=line_items(:without_user)
    old_quantity=line_item.quantity
    new_quantity=old_quantity*5
    attr_hash={line_items_attributes: [{id: line_item.id, quantity: new_quantity}]}
    assert_not order.line_items.include?(line_item)
    assert_raises ActiveRecord::RecordNotFound do
      order.update_attributes(attr_hash)
    end
    order.reload
    line_item.reload
    assert_equal old_quantity, line_item.quantity
    assert_not order.line_items.include?(line_item)
  end

  test "should not be able to place order if line items would reduce current stock less than 0" do
    order=Cart.create(valid)
    line_item=order.line_items.first
    stock_level=line_item.product.stock_levels.current.first
    line_item.quantity=stock_level.current_quantity+1
    assert line_item.save
    order.reload
    order.status=:placed
    assert_not order.valid?, "order: #{order.inspect}"
    assert_not order.save, "order: #{order.inspect}"
  end

=begin
#All assertions are what I believe should be the behaviour
#Comments are observed behaviour
  test "odd behaviour with dirty bits" do
    order=Cart.create(valid)
    line_item=order.line_items.first
    stock_level=line_item.product.stock_levels.current.first
    line_item.quantity=stock_level.current_quantity+1
    assert line_item.changed? #passes
    assert order.line_items.first.changed? #fails
    assert order.changed? #fails
    assert line_item.save #passes
    assert_not line_item.changed? #passes
    assert_not order.line_items.first.changed? #passes
    assert_not order.changed? #passes
    order.status=:placed
    assert order.changed? #passes
    assert_not order.line_items.any?(&:changed?), "Debug: #{order.line_items.map(&:changed).join(" ")}" #fails: updated_at & quantity
    assert_not order.valid?, "order: #{order.inspect}" 
    assert_not order.save, "order: #{order.inspect}"
  end
=end

  test "should decrement current stock when placing order" do
    order=Cart.create(valid)
    line_item=order.line_items.first
    stock_level=line_item.product.stock_levels.current.first
    old_quantity=stock_level.current_quantity
    order.reload
    order.status=:placed
    assert_difference "Allocation.count" do
      assert order.save, "order: #{order.errors.inspect}: line_items: #{order.line_items.map{|l| l.changed.map{|c| "#{c}: #{l.send(c)} was: #{l.send(c+"_was")}"}}.join(" ")}"
    end
    stock_level.reload
    assert_equal old_quantity-line_item.quantity, stock_level.current_quantity
  end

  test "should not decrement current stock when adding to cart" do
    old_stock=products(:mug).stock_levels.current.map(&:current_quantity).sum
    order=Cart.create(valid)
    assert_no_difference "Allocation.count" do
      assert_equal old_stock, products(:mug).stock_levels.current.map(&:current_quantity).sum
    end
  end

  test "should not decrement current stock when saving a placed order multiple times" do
    order=Cart.create(valid)
    order.placed!
    old_stock=products(:mug).stock_levels.current.map(&:current_quantity).sum
    assert_no_difference "Allocation.count" do
      order.save
    end
    assert_equal old_stock, products(:mug).stock_levels.current.map(&:current_quantity).sum
  end

  test "should remove line items on deletion" do
    order=Cart.create(valid)
    assert_difference "LineItem.count", -1 do
      order.destroy
    end
  end
  
  test "should respond to delivery_address" do
    order=Cart.new
    assert_respond_to order, :delivery_address
  end

  test "should contain delivery address" do
    order=orders(:with_addresses)
    assert_not_nil orders(:with_addresses).delivery_address
    assert_equal addresses(:order_delivery), orders(:with_addresses).delivery_address
  end

  test "should contain billing addrsss" do
    order=orders(:with_addresses)
    assert_not_nil orders(:with_addresses).billing_address
    assert_equal addresses(:order_billing), orders(:with_addresses).billing_address
  end
  test "should respond to billing addrsss" do
    order=Order.new
    assert_respond_to order, :billing_address
  end

  private
    def valid
      @order||={user: users(:buyer), line_items_attributes: [{product_id: products(:mug).id, quantity: 1}]}
    end
end
