require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  test "should be able to browse to product index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should contain a list of products" do
    get :index
    assert_not_nil assigns(:products)
    item_count=[Product.count, 30].min
    assert_select "div.product_list div", item_count do
      assert_select "a"
    end
  end

end
