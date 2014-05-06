require 'test_helper'

class GiftCardProductTest < ActiveSupport::TestCase
  test "should tell us it's a Product when asked" do
    assert_equal Product.model_name, GiftCardProduct.model_name
  end
end
