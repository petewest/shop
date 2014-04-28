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
    postage=PostageCost.new(valid.except(:unit_cost))
    assert_not postage.save
  end

  test "should not save when cost is non-numeric" do
    postage=PostageCost.new(valid.merge(unit_cost: "gold bullion"))
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
    range_checks={}
    range_checks[:lower_bound]=PostageCost.new(valid.merge(from_weight: valid[:to_weight]-1, to_weight: valid[:to_weight]+20))
    range_checks[:upper_bound]=PostageCost.new(valid.merge(from_weight: valid[:from_weight]-20, to_weight: valid[:from_weight]+1))
    range_checks[:contained_in]=PostageCost.new(valid.merge(from_weight: valid[:from_weight]-1, to_weight: valid[:to_weight]+20))
    range_checks[:contains]=PostageCost.new(valid.merge(from_weight: valid[:from_weight]+1, to_weight: valid[:to_weight]-1))
    range_checks[:equals]=PostageCost.new(valid)
    range_checks.each do |key, test|
      assert_not test.save, "Debug: #{key.inspect}: #{test.inspect}"
    end
  end

  test "should allow overlap if postage_service differs" do
    postage=PostageCost.create(valid)
    postage2=postage.dup
    postage2.postage_service=postage_services(:second_class)
    assert postage2.save
  end

  test "should allow lower bound of this to touch upper bound of other record" do
    postage=PostageCost.new(valid)
    postage.save
    postage2=PostageCost.new(valid.merge(from_weight: valid[:to_weight], to_weight: valid[:to_weight]+20))
    assert postage2.save
  end

  test "should allow upper bound of this to touch lower bound of other record" do
    postage=PostageCost.new(valid)
    postage.save
    postage2=PostageCost.new(valid.merge(from_weight: valid[:from_weight]-10, to_weight: valid[:from_weight]))
    assert postage2.save
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

  test "should not save without postage_service" do
    postage=PostageCost.new(valid.except(:postage_service))
    assert_not postage.valid?
    assert_not postage.save
  end

  private
    def valid
      @postage_cost||={postage_service: postage_services(:first_class), from_weight: 20, to_weight: 50, unit_cost: 80, currency: currencies(:gbp)}
    end
end
