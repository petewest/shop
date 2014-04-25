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

  test "should respond to cost" do
    order=Order.new
    assert_respond_to order, :cost
  end

  test "should contain sum of line items in cost" do
    order=Order.new
    product=products(:tshirt)
    order.products=[product]
    order.line_items.first.quantity=2
    order.line_items.each(&:copy_cost_from_product)
    postage_cost=PostageCost.for_weight(product.weight*2)
    assert currencies(:gbp), order.currency
    assert_equal (product.cost*2)+postage_cost.cost, order.cost
  end

  test "should not allow multi-currency orders" do
    order=Order.new
    products=[products(:tshirt), products(:mug)]
    order.products=products
    assert order.save
    assert_raises ActiveRecord::RecordNotSaved do
      order.products<<products(:other_currency)
    end
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
    product1=products(:mug)
    product2=products(:tshirt)
    order=Cart.create(valid.merge(line_items_attributes:[{product_id: product1.id, quantity: 2}, {product_id: product2.id, quantity: 1}]))
    line_item=order.line_items.first
    stock_level=line_item.product.stock_levels.current.first
    old_quantity=stock_level.current_quantity
    order.reload
    order.status=:placed
    assert_difference "Allocation.count",2 do
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
    assert_respond_to order, :delivery
  end

  test "should respond to billing addrsss" do
    order=Order.new
    assert_respond_to order, :billing
  end

  test "should save without delivery address on cart" do
    order=Cart.new(valid.except(:delivery))
    assert order.save
  end

  test "should save without billing address on cart" do
    order=Cart.new(valid.except(:billing))
    assert order.save
  end


  test "should not save when delivery address empty" do
    order=Order.create(valid.except(:delivery_attributes))
    #to switch to placed create the order in cart mode first
    #otherwise you can't add line items straight to placed mode
    order.status=:placed
    assert_not order.save
  end

  test "should not save when billing address empty" do
    order=Order.create(valid.except(:billing_attributes))
    order.status=:placed
    assert_not order.save
  end

  test "should delete orderaddresses on destroy" do
    order=orders(:placed)
    assert_difference "OrderAddress.count", -2 do
      order.destroy
    end
  end

  test "should respond to total_weight" do
    order=Order.new
    assert_respond_to order, :total_weight
  end

  test "should respond to postage_cost" do
    order=Order.new
    assert_respond_to order, :postage_cost
  end

  test "should give total cost including postage" do
    product=products(:with_weight)
    quantity=5
    postage_cost=PostageCost.for_weight(product.weight*quantity)
    order=Order.create(valid.merge(line_items_attributes: [{product_id: product.id, quantity: quantity}]))
    assert_equal postage_cost, order.postage_cost
    assert_equal (product.cost*quantity)+postage_cost.cost, order.cost, "product_cost: #{product.unit_cost*quantity}, postage_cost: #{postage_cost.unit_cost}."
  end

  test "should record time when changing status to placed" do
    order=Order.create(valid)
    assert_nil order.placed_at
    order.placed!
    assert_not_nil order.placed_at
  end

  test "should record time when changing status to dispatched" do
    order=orders(:paid)
    assert_nil order.dispatched_at
    order.dispatched!
    assert_not_nil order.dispatched_at
  end

  test "should not be able to progress an order from cart to dispatched" do
    order=Order.create(valid)
    assert_raises ActiveRecord::RecordInvalid do
      order.dispatched!
    end
    order.reload
    assert_not order.dispatched?
  end

  test "should be able to move an order from cancelled to cart" do
    order=orders(:cancelled)
    assert_difference "Cart.count" do
      order.cart!
    end
    order.reload
    assert_equal "cart", order.status
    assert_equal "Cart", order.type, "Debug: #{order.inspect}"
  end

  test "should release stock when the order is cancelled" do
    order=orders(:placed)
    assert_difference "Allocation.count", -1 do
      assert_difference "stock_levels(:product_0).reload.current_quantity" do
        order.cancelled!
      end
    end
  end

  test "should respond to reconcile_charge" do
    order=Order.new
    assert_respond_to order, :reconcile_charge
  end

  test "should respond to fix_postage" do
    order=Order.new
    assert_respond_to order, :fix_costs
  end

  test "should set postage_cost_id on fix_costs" do
    product=products(:with_weight)
    quantity=5
    postage_cost=PostageCost.for_weight(product.weight*quantity)
    order=Order.create(valid.merge(line_items_attributes: [{product_id: product.id, quantity: quantity}]))
    order.fix_costs
    assert_equal postage_cost.id, order.postage_cost_id
  end

  test "should fix costs, currency and postage on placing" do
    product=products(:with_weight)
    quantity=5
    postage_cost=PostageCost.for_weight(product.weight*quantity)
    order=Order.create(valid.merge(line_items_attributes: [{product_id: product.id, quantity: quantity}]))
    order.reload
    assert_nil order.postage_cost_id
    assert_nil order.unit_cost
    assert_nil order.currency_id
    order.placed!
    order.reload
    assert_equal postage_cost.id, order.postage_cost_id, "Debug postage cost id missing"
    assert_equal product.cost*quantity+postage_cost.cost, order.unit_cost, "Debug: Cost doesn't match"
    assert_equal product.currency_id, order.currency_id, "Debug: Currency id isn't set"
  end

  test "should retrieve cost from model when set and force-fix when told" do
    product=products(:with_weight)
    quantity=5
    postage_cost=PostageCost.for_weight(product.weight*quantity)
    postage_cost_other=PostageCost.where.not(id: postage_cost.id).first
    currency_other=Currency.where.not(id: product.currency.id).first
    order=Order.create(valid.merge(line_items_attributes: [{product_id: product.id, quantity: quantity}]))
    order.placed!
    order.postage_cost_id=postage_cost_other.id
    order.currency_id=currency_other.id
    order.unit_cost=20
    order.save and order.reload
    assert_equal postage_cost_other, order.postage_cost
    assert_equal currency_other, order.currency
    assert_equal 20, order.cost
    order.fix_costs!
    order.reload
    assert_not_equal postage_cost_other, order.postage_cost
    assert_not_equal currency_other, order.currency
    assert_not_equal 20, order.cost
  end

  private
    def valid
      @order||={user: users(:buyer), billing_attributes: { source_address: users(:buyer).addresses.billing.first}, delivery_attributes: {source_address: users(:buyer).addresses.delivery.first}, line_items_attributes: [{product_id: products(:mug).id, quantity: 1}]}
    end
end
