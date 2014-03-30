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

  test "should not save if order status is anything other than cart" do
    line_item=LineItem.new(valid.merge(order: orders(:paid)))
    assert_not line_item.save
  end

  private
    def valid
      @line_item||={product: products(:tshirt), order: orders(:cart), quantity: 1}
    end

end
