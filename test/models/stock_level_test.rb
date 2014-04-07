require 'test_helper'

class StockLevelTest < ActiveSupport::TestCase
  test "should create when valid" do
    stock=StockLevel.new(valid)
    assert stock.save
  end

  test "should not save without product" do
    stock=StockLevel.new(valid.except(:product))
    assert_not stock.valid?
    assert_not stock.save
  end

  test "should not save without due date" do
    stock=StockLevel.new(valid.except(:due_at))
    assert_not stock.valid?
    assert_not stock.save
  end

  test "should have current scope" do
    assert_respond_to StockLevel, :current
  end

  test "should not give future stock in current" do
    sl=StockLevel.current
    assert_not sl.include?(stock_levels(:future_stock))
    assert_not sl.include?(stock_levels(:expired))
    assert_not sl.include?(stock_levels(:sold_out))
    assert sl.include?(stock_levels(:tshirt_stock))
  end

  test "should respond to expires_at" do
    sl=StockLevel.new
    assert_respond_to sl, :expires_at
  end

  test "should fail to save if start_quantity is not a number" do
    sl=StockLevel.new(valid.merge(start_quantity: "elephant"))
    assert_not sl.save
  end

  test "should fail to save if current_quantity is not a number" do
    sl=StockLevel.new(valid.merge(current_quantity: "elephant"))
    assert_not sl.save
  end

  test "should fail to save if start_quantity is not an integer" do
    sl=StockLevel.new(valid.merge(start_quantity: 10.5))
    assert_not sl.save
  end

  test "should fail to save if current_quantity is not an integer" do
    sl=StockLevel.new(valid.merge(current_quantity: 10.5))
    assert_not sl.save
  end

  test "should fail to save without start_quantity" do
    sl=StockLevel.new(valid.except(:start_quantity))
    assert_not sl.save
  end

  test "should set current_quantity to be start if current is nil" do
    sl=StockLevel.new(valid.except(:current_quantity))
    assert sl.save
    assert_equal sl.start_quantity, sl.current_quantity
  end

  test "should not overwrite current quantity if already set" do
    sl=StockLevel.new(valid.merge(current_quantity: 5))
    sl.save
    sl.reload
    assert_equal 5, sl.current_quantity
  end

  test "should not allow current to be more than start" do
    sl=StockLevel.new(valid)
    sl.current_quantity=sl.start_quantity+1
    assert_not sl.save
  end

  test "should not allow negative current_quantity" do
    sl=StockLevel.new(valid.merge(current_quantity: -1))
    assert_not sl.save
  end


  private
    def valid
      @stock||={product: products(:mug), due_at: '2014-04-03', start_quantity: 20}
    end
end
