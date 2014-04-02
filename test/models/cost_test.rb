require 'test_helper'

class CostTest < ActiveSupport::TestCase
  test "should respond to currency" do
    cost=Cost.new
    assert_respond_to cost, :currency
  end

  test "should save when valid" do
    cost=Cost.new(valid)
    assert cost.save
  end

  test "should not save without currency" do
    cost=Cost.new(valid.except(:currency))
    assert_not cost.save
  end

  test "should not save without costable" do
    cost=Cost.new(valid.except(:costable))
    assert_not cost.save
  end

  test "should not save without value" do
    cost=Cost.new(valid.except(:value))
    assert_not cost.save
  end

  test "should not save without numeric value" do
    cost=Cost.new(valid.merge(value: "elephant"))
    assert_not cost.save
  end

  private
    def valid
      @cost||={currency: currencies(:gbp), costable: products(:tshirt), value: 20}
    end
end
