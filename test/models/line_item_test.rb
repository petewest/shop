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

end
