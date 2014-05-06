require 'test_helper'

class GiftCardProductTest < ActiveSupport::TestCase
  test "should have name of 'Gift card'" do
    assert_equal "Gift Card", GiftCardProduct.new.name
  end
end
