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



  private
    def valid
      @stock||={product: products(:mug), due_at: '2014-04-03', start_quantity: 20}
    end
end
