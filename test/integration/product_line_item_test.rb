require 'test_helper'

class ProductLineItemTest < ActionDispatch::IntegrationTest
  fixtures :products

  test "should route to line item controller on buy" do
    assert_routing '/products/1/buy', controller: 'line_items', action: 'new', product_id: "1"
  end

  test "should show new line item page" do
    product=products(:tshirt)
    get url_for [product, :buy]
    assert_response :success
    assert_not_nil assigns(:line_item)
    assert_select "form"
  end
end
