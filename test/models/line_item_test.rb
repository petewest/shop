require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  test "should respond to order" do
    line_item=LineItem.new
    assert_respond_to line_item, :order
  end

  test "should respond to product" do
    line_item=LineItem.new
    assert_respond_to line_item, :product
  end

  test "should respond to allocations" do
    line_item=LineItem.new
    assert_respond_to line_item, :allocations
  end

  test "should not allow negative quantity" do
    line_item=LineItem.new(valid.merge(quantity: -1))
    assert_not line_item.valid?
  end

  test "should save when valid" do
    line_item=LineItem.new(valid)
    assert line_item.save
  end

  test "should not save without product" do
    line_item=LineItem.new(valid.except(:product))
    assert_not line_item.save
  end

  test "should not save without order" do
    line_item=LineItem.new(valid.except(:order))
    assert_not line_item.save
  end

  test "should set quantity to be one when missing" do
    line_item=LineItem.new(valid.except(:quantity))
    assert_equal 1, line_item.quantity
  end

  test "should not save if order status is paid or dispatched" do
    line_item_paid=LineItem.new(valid.merge(order: orders(:paid)))
    line_item_dispatched=LineItem.new(valid.merge(order: orders(:dispatched)))
    assert_not line_item_paid.save
    assert_not line_item_dispatched.save
  end

  test "should respond to copy_cost_from_product" do
    line_item=LineItem.new
    assert_respond_to line_item, :copy_cost_from_product
  end

  test "should copy_cost_from_product" do
    line_item=LineItem.new(valid)
    assert line_item.save
    assert_not_nil line_item.cost
    assert_equal line_item.product.currency, line_item.currency
    assert_equal line_item.product.cost, line_item.cost
  end

  test "should not allow duplicate products in same order" do
    line_item=LineItem.new(valid)
    line_item.save
    line_item=line_item.dup
    assert_not line_item.save
  end

  test "should override currency and cost from product on save" do
    line_item=LineItem.new(valid)
    line_item.unit_cost=2_000_000
    line_item.currency=currencies(:usd)
    assert line_item.save
    line_item.reload
    assert_not_equal 2_000_000, line_item.unit_cost
    assert_not_equal currencies(:usd), line_item.currency
  end

  test "should copy unit cost from product" do
    line_item=LineItem.new(valid)
    line_item.save
    assert_not_nil line_item.unit_cost
  end

  test "cost should equal unit_cost*quantity" do
    line_item=LineItem.new(valid)
    line_item.quantity=2
    line_item.save
    assert_equal line_item.product.unit_cost, line_item.unit_cost
    assert_equal line_item.product.cost*line_item.quantity, line_item.cost
  end

  test "should remove stock allocation on destroy" do
    line_item=LineItem.new(valid)
    line_item.quantity=2
    line_item.save
    #ensure we have stock
    stock=line_item.product.stock_levels.new(due_at: 5.minutes.ago, start_quantity: 10)
    assert stock.save
    line_item.reload
    assert_difference "Allocation.count" do
      line_item.take_stock
    end
    assert_difference "Allocation.count", -1 do
      line_item.destroy
    end
  end

  test "should split across stock levels when available" do
    line_item=LineItem.new(valid)
    line_item.quantity=20
    assert line_item.save
    stock=line_item.product.stock_levels.new(due_at: 2.days.ago, start_quantity: 5)
    assert stock.save
    stock2=line_item.product.stock_levels.new(due_at: 1.day.ago, start_quantity: 10)
    assert stock2.save
    stock3=line_item.product.stock_levels.new(due_at: 5.minutes.ago, start_quantity: 8)
    assert stock3.save
    stock4=line_item.product.stock_levels.new(due_at: 5.minutes.ago, start_quantity: 5)
    assert stock4.save
    line_item.reload
    assert_equal 4, line_item.product.stock_levels.count
    assert_difference "Allocation.count", 3, "allocations: #{line_item.allocations.inspect}" do
      line_item.take_stock
    end
  end

  test "should respond to weight" do
    line_item=LineItem.new
    assert_respond_to line_item, :weight
  end

  test "should be weight of product times quantity" do
    product=products(:with_weight)
    line_item=LineItem.new(valid.merge(product: product, quantity: 20))
    assert_equal product.weight*20, line_item.weight
  end

  test "should respond to release_stock" do
    line_item=LineItem.new
    assert_respond_to line_item, :release_stock
  end

  test "should release stock when told" do
    line_item=line_items(:two)
    assert_difference "Allocation.count", -1 do
      line_item.release_stock
    end
  end

  test "should not create new item if product not for sale" do
    line_item=LineItem.new(valid.merge(product: products(:not_for_sale)))
    assert_not line_item.valid?
    assert_equal 1, line_item.errors.count
    assert_equal "not for sale", line_item.errors[:product].join
  end

  private
    def valid
      @line_item||={product: products(:product_20), order: orders(:cart), quantity: 1}
    end

end
