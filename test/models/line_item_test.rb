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
    line_item.copy_cost_from_product
    assert line_item.valid?
    assert_not_nil line_item.cost
    assert_equal line_item.product.cost.currency, line_item.cost.currency
    assert_equal line_item.product.cost.value, line_item.cost.value
  end


  private
    def valid
      @line_item||={product: products(:tshirt), order: orders(:cart), quantity: 1, cost_attributes: {currency: currencies(:gbp), value: 200}}
    end

end
