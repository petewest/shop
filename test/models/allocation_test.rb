require 'test_helper'

class AllocationTest < ActiveSupport::TestCase
  test "should create if valid" do
    a=Allocation.new(valid)
    assert a.save, "Debug: #{a.errors.inspect}"
  end

  test "should not create a duplicate line/stock combo" do
    a=Allocation.new(valid)
    assert a.save
    a=a.dup
    assert_not a.save
  end

  test "should not save without line_item" do
    a=Allocation.new(valid.except(:line_item))
    assert_not a.valid?
    assert_not a.save
  end

  test "should not save without stock_level" do
    a=Allocation.new(valid.except(:stock_level))
    assert_not a.valid?
    assert_not a.save
  end

  test "should not save if quantity is non-numeric" do
    a=Allocation.new(valid.merge(quantity: "elephant"))
    assert_not a.valid?
    assert_not a.save
  end

  test "should not save if quantity is float" do
    a=Allocation.new(valid.merge(quantity: 1.5))
    assert_not a.valid?
    assert_not a.save
  end

  test "should not save if quantity is negative" do
    a=Allocation.new(valid.merge(quantity: -1))
    assert_not a.valid?
    assert_not a.save
  end

  test "should not save if quantity is zero" do
    a=Allocation.new(valid.merge(quantity: 0))
    assert_not a.valid?
    assert_not a.save
  end

  test "should respond to release_stock" do
    allocation=Allocation.new
    assert_respond_to allocation, :release_stock
  end

  test "should give stock back on release" do
    allocation=Allocation.new(valid)
    allocation.stock_level.current_quantity-=allocation.quantity
    allocation.save
    assert_difference "allocation.stock_level.current_quantity", allocation.quantity do
      allocation.release_stock
    end
  end

  test "should take allocation out of stock level on save" do
    allocation=Allocation.new(valid)
    assert_difference "allocation.stock_level.current_quantity", -1*allocation.quantity do
      allocation.save
    end
  end

  private
    def valid
      @alloc||={line_item: line_items(:one), stock_level: stock_levels(:tshirt_stock), quantity: 1}
    end
end
