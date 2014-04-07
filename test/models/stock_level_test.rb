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



  private
    def valid
      @stock||={product: products(:mug), due_at: '2014-04-03', start_quantity: 20}
    end
end
