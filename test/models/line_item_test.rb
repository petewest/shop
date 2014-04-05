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
    line_item=LineItem.new(valid.except(:cost_attributes))
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


  private
    def valid
      @line_item||={product: products(:product_20), order: orders(:cart), quantity: 1}
    end

end
