require 'test_helper'

class StockLevelsControllerTest < ActionController::TestCase
  test "should not be accessible from non-seller account" do
    product=products(:tshirt)
    get product_stock_levels_path(product)
    assert_response :redirect
  end

end
