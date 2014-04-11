require 'test_helper'

class PostageCostTest < ActiveSupport::TestCase
  test "should save when valid" do
    postage=PostageCost.new(valid)
    assert postage.save
  end

  test "should not save without weights" do
    postage=PostageCost.new(valid.except(:from_weight, :to_weight))
    assert_not postage.save
  end

  test "should not save when weights are non-numeric" do
    postage=PostageCost.new(valid.merge(from_weight: "albatross", to_weight: "elephant"))
    assert_not postage.save
  end

  test "should not save without cost" do
    postage=PostageCost.new(valid.except(:cost))
    assert_not postage.save
  end

  test "should not save when cost is non-numeric" do
    postage=PostageCost.new(valid.merge(cost: "gold bullion"))
    assert_not postage.save
  end

  test "should not save without currency" do
    postage=PostageCost.new(valid.except(:currency))
    assert_not postage.save
  end

  test "should not save when from>to weight" do
    postage=PostageCost.new(valid.merge(from_weight: valid[:to_weight]+10))
    assert_not postage.save
  end

  test "should not allow negative from_weight" do
    postage=PostageCost.new(valid.merge(from_weight: -1))
    assert_not postage.save
  end

  test "should not overlap other ranges" do
    postage=PostageCost.new(valid)
    postage.save
    postage2=PostageCost.new(valid.merge(from_weight: valid[:to_weight]-1, to_weight: valid[:to_weight]+20))
    assert_not postage2.save
  end

  test "should respond to for_weight" do
    assert_respond_to PostageCost, :for_weight
  end

  test "should return entry for a given weight" do
    postage=PostageCost.new(valid)
    postage.save
    assert_equal postage, PostageCost.for_weight(30)
  end

  test "should return when weight equals upper boundary" do
    postage=PostageCost.new(valid)
    postage.save
    assert_equal postage, PostageCost.for_weight(valid[:to_weight])
  end

  test "should not return when weight equals lower boundary" do
    postage=PostageCost.new(valid)
    postage.save
    assert_not_equal postage, PostageCost.for_weight(valid[:from])
  end

  private
    def valid
      @postage_cost||={from_weight: 20, to_weight: 50, cost: 80, currency: currencies(:gbp)}
    end
end
